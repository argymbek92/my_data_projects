from typing import List
from fastapi import Depends, FastAPI, HTTPException 
from sqlalchemy.orm import Session 
from sqlalchemy.sql import func
from database import SessionLocal 
from table_post import Post 
from table_user import User
from table_feed import Feed 
from schema import UserGet, PostGet, FeedGet
 
app = FastAPI() 
 
def get_db():
  with SessionLocal() as db:
    return db 
      
@app.get("/post/recommendations", response_model = List[PostGet]) 
def get_recommendations(id: int, limit: int = 10, db: Session = Depends(get_db)): 
    result = (db.query(Post)
              .select_from(Feed)
              .filter(Feed.action == 'like')
              .join(Post, Post.id == Feed.post_id)
              .group_by(Post.id)
              .order_by(func.count(Post.id).desc())
              .limit(limit)
              .all()
              )
    return result
