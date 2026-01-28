import os
import pandas as pd
from catboost import CatBoostClassifier
from pydantic import BaseModel 
from fastapi import FastAPI
from sqlalchemy import create_engine, Column, Integer, String, text, Index
from typing import List

from datetime import datetime

# Импорт модели данных
class PostGet(BaseModel):
    id: int
    text: str
    topic: str

    class Config:
        orm_mode = True

# Определение класса для входящих данных
class UserRequest(BaseModel):
    id: int
    text: str
    topic: str

# Создание экземпляра FastAPI
app = FastAPI()


def get_model_path(path: str) -> str:
    if os.environ.get("IS_LMS") == "1":  # проверяем где выполняется код в лмс, или локально. Немного магии
        MODEL_PATH = '/workdir/user_input/model'
    else:
        MODEL_PATH = path
    return MODEL_PATH
    
# Функция для загрузки модели
def load_models():
    model_path = get_model_path("C:/Users/argym/Desktop/final_project_part_2/catboost_model")
    loaded_model= CatBoostClassifier()
    loaded_model.load_model(model_path, format="cbm")
    return loaded_model

def batch_load_sql(query: str):
    CHUNKSIZE = 200000
    engine = create_engine(
        "postgresql://robot-startml-ro:pheiph0hahj1Vaif@"
        "postgres.lab.karpov.courses:6432/startml"
    )
    conn = engine.connect().execution_options(stream_results=True)
    chunks = []
    for chunk_dataframe in pd.read_sql(query, conn, chunksize=CHUNKSIZE):
        chunks.append(chunk_dataframe)
    conn.close()
    return pd.concat(chunks, ignore_index=True)

def load_features():
    unique_liked_posts = """
        SELECT distinct user_id, post_id
        FROM public.feed_data
        where action='like'"""
    liked_posts = batch_load_sql(unique_liked_posts)

    posts_features = pd.read_sql(
        """SELECT * FROM public.post_text_df""",

        con="postgresql://robot-startml-ro:pheiph0hahj1Vaif@"
        "postgres.lab.karpov.courses:6432/startml"
    )

    user_features = pd.read_sql(
        """SELECT * FROM public.user_data""",

        con="postgresql://robot-startml-ro:pheiph0hahj1Vaif@"
        "postgres.lab.karpov.courses:6432/startml"
    )
    
    return [user_features, posts_features, liked_posts]

# Загрузка модели вне эндпоинта
model = load_models()
features = load_features()

def get_recommended_feed(id: int, time: datetime, limit: int):
    user_features = features[0].loc[features[0].user_id == id]
    user_features = user_features.drop('user_id', axis=1)

    posts_features = features[1].drop(['text'], axis=1)
    content = features[1][['post_id', 'text', 'topic']]

    add_user_features = dict(zip(user_features.columns, user_features.values[0]))
    user_posts_features = posts_features.assign(**add_user_features)
    user_posts_features = user_posts_features.set_index('post_id')

    user_posts_features['hour'] = time.hour
    user_posts_features['month'] = time.month

    predicts = model.predict_proba(user_posts_features)[:, 1]
    user_posts_features['predicts'] = predicts

    liked_posts = features[2]
    liked_posts = liked_posts[liked_posts.user_id == id].post_id.values
    filtered_ = user_posts_features[~user_posts_features.index.isin(liked_posts)]

    recommended_posts = filtered_.sort_values('predicts')[-limit:].index

    return[
        PostGet(**{
            'id': i,
            'text': content[content.post_id == i].text.values[0],
            'topic': content[content.post_id == i].topic.values[0]
        }) for i in recommended_posts
    ]
     
@app.get("/post/recommendations/", response_model=List[PostGet])
def recommended_posts(id: int, time: datetime, limit: int = 10) -> List[PostGet]:
    return get_recommended_feed(id, time, limit)
