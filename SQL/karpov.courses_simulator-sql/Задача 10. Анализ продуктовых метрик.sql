/* Задача 2.
Теперь на основе данных о выручке рассчитаем несколько относительных показателей, которые покажут, сколько в среднем потребители готовы платить за услуги нашего сервиса доставки. Остановимся на следующих метриках:
1. ARPU (Average Revenue Per User) — средняя выручка на одного пользователя за определённый период.
2. ARPPU (Average Revenue Per Paying User) — средняя выручка на одного платящего пользователя за определённый период.
3. AOV (Average Order Value) — средний чек, или отношение выручки за определённый период к общему количеству заказов за это же время.

Если за рассматриваемый период сервис заработал 100 000 рублей и при этом им пользовались 500 уникальных пользователей, из которых 400 сделали в общей сложности 650 заказов, тогда метрики будут иметь следующие значения:
ARPU =100000/500=200     ARPPU =100000/400=250      AOV=100000/650≈153,85

Задание:
Для каждого дня в таблицах orders и user_actions рассчитайте следующие показатели:

Выручку на пользователя (ARPU) за текущий день.
Выручку на платящего пользователя (ARPPU) за текущий день.
Выручку с заказа, или средний чек (AOV) за текущий день.
Колонки с показателями назовите соответственно arpu, arppu, aov. Колонку с датами назовите date. 

При расчёте всех показателей округляйте значения до двух знаков после запятой. Результат должен быть отсортирован по возрастанию даты. Поля в результирующей таблице: date, arpu, arppu, aov */

--на дату вывести
--1.число всех пользователей уникальных
--2.число пользователей, которые совершили заказ и не отменили его
--3.число заказов, которые совершили платящие пользователи */
with x1 as (SELECT creation_time::date as date,
                   order_id,
                   unnest(product_ids) as product_id
            FROM   orders), x2 as (SELECT date,
                              order_id,
                              product_id,
                              name,
                              price,
                              user_id
                       FROM   x1
                           LEFT JOIN products using(product_id)
                           LEFT JOIN user_actions using(order_id)), x3 as (SELECT date,
                                                           count(distinct user_id) as users,
                                                           count(distinct order_id) as orders,
                                                           sum(price) as revenue
                                                    FROM   x2
                                                    WHERE  order_id not in (SELECT order_id
                                                                            FROM   user_actions
                                                                            WHERE  action = 'cancel_order')
                                                    GROUP BY date
                                                    ORDER BY date), x4 as (SELECT date,
                              count(distinct user_id) as new_users
                       FROM   (SELECT time::date as date,
                                      user_id
                               FROM   user_actions
                               GROUP BY user_id, time::date) t
                       GROUP BY date), x5 as (SELECT date,
                              users,
                              orders,
                              new_users,
                              revenue
                       FROM   x3
                           LEFT JOIN x4 using(date))
SELECT date,
       round(revenue::decimal/new_users, 2) as arpu,
       round(revenue::decimal/users, 2) as arppu,
       round(revenue::decimal/orders, 2) as aov
FROM   x5
