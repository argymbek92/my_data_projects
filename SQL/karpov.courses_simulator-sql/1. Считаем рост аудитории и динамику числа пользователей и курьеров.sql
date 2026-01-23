/* Задача 1.
Для начала давайте проанализируем, насколько быстро растёт аудитория нашего сервиса, и посмотрим на динамику числа 
пользователей и курьеров. 
Задание: Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитайте следующие показатели:

Число новых пользователей.
Число новых курьеров.
Общее число пользователей на текущий день.
Общее число курьеров на текущий день.

Колонки с показателями назовите соответственно new_users, new_couriers, total_users, total_couriers. 
Колонку с датами назовите date. Проследите за тем, чтобы показатели были выражены целыми числами. 
Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, new_users, new_couriers, total_users, total_couriers */
with x1 as (SELECT min(time)::date as date,
                   user_id
            FROM   user_actions
            WHERE  order_id in (SELECT order_id
                                FROM   user_actions
                                WHERE  action != 'cancel_order')
            GROUP BY user_id), x2 as (SELECT courier_id,
                                 min(time)::date as date
                          FROM   courier_actions
                          WHERE  order_id in (SELECT order_id
                                              FROM   user_actions
                                              WHERE  action != 'cancel_order')
                          GROUP BY courier_id), x3 as (SELECT date,
                                    user_id,
                                    courier_id
                             FROM   x1
                                 LEFT JOIN x2 using(date))
SELECT date,
       count(distinct user_id) as new_users,
       count(distinct courier_id) as new_couriers,
       sum(count(distinct user_id)) OVER(ORDER BY date)::integer as total_users,
       sum(count(distinct courier_id)) OVER(ORDER BY date)::integer as total_couriers
FROM   x3
GROUP BY date
