Baseline для финального проекта

Напишите endpoint GET /post/recommendations/, который принимает query-parameters id и limit (limit должен быть по умолчанию равным 10).
NB: в этом эндпоинте важно прописать слэш в конце, чтобы FastAPI различал эндпоинты /post/recommendations/ и /post/{id}.  
API должна возвращать структуру List[PostGet] (класс PostGet вы описывали в предыдущих заданиях).
Этот endpoint должен вернуть топ limit постов по количеству лайков. 
Более формально: необходимо подсчитать количество лайков для каждого поста, отсортировать по убыванию и выдать первые limit записей постов (их id, text и topic). 
Параметр id в этом задании использован не будет, он понадобится вам для сдачи финального проекта.
Для справки приводим SQL-запрос, который выведет топ постов по лайку - пары (id, количество_лайков):
SELECT f.post_id, COUNT(f.post_id)
FROM feed_action f
WHERE f.action = 'like'
GROUP BY f.post_id
ORDER BY COUNT(f.post_id) DESC
LIMIT 10
;
