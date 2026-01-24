/* Задача 5.*
Продолжим изучать наш сервис и рассчитаем несколько показателей, связанных с заказами.

Задание:

Для каждого дня, представленного в таблице user_actions, рассчитайте следующие показатели:

Общее число заказов.
Число первых заказов (заказов, сделанных пользователями впервые).
Число заказов новых пользователей (заказов, сделанных пользователями в тот же день, 
когда они впервые воспользовались сервисом).
Долю первых заказов в общем числе заказов (долю п.2 в п.1).
Долю заказов новых пользователей в общем числе заказов (долю п.3 в п.1).
Колонки с показателями назовите соответственно orders, first_orders, new_users_orders, 
first_orders_share, new_users_orders_share. Колонку с датами назовите date. 
Проследите за тем, чтобы во всех случаях количество заказов было выражено целым числом. 
Все показатели с долями необходимо выразить в процентах. 
При расчёте долей округляйте значения до двух знаков после запятой.

Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, orders, first_orders, new_users_orders, first_orders_share, new_users_orders_share */
with x1 as (SELECT time::date as date,
                   count(order_id) as orders
            FROM   user_actions
            WHERE  order_id not in (SELECT order_id
                                    FROM   user_actions
                                    WHERE  action = 'cancel_order')
            GROUP BY date
            ORDER BY date), x2 as (SELECT date,
                              count(user_id) as first_orders FROM(SELECT min(time::date) as date,
                                                                  user_id
                                                           FROM   user_actions
                                                           WHERE  order_id not in (SELECT order_id
                                                                                   FROM   user_actions
                                                                                   WHERE  action = 'cancel_order')
                                                           GROUP BY user_id) t
                       GROUP BY date
                       ORDER BY date), x3 as (SELECT min(time::date) as date,
                              user_id
                       FROM   user_actions
                       GROUP BY user_id
                       ORDER BY date), x4 as (SELECT time::date as date,
                              user_id,
                              order_id
                       FROM   user_actions
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')), x5 as (SELECT x3.date,
                                                count(x4.order_id) as new_users_orders
                                         FROM   x3
                                             LEFT JOIN x4
                                                 ON x3.date = x4.date and
                                                    x3.user_id = x4.user_id
                                         GROUP BY x3.date
                                         ORDER BY x3.date), x6 as (SELECT date,
                                 orders,
                                 first_orders,
                                 new_users_orders
                                 -- ROUND(100*(first_orders::decimal/ orders), 2) AS first_orders_share,
                                 -- ROUND(100*(new_users_orders::decimal/ orders), 2) AS new_users_orders_share
                          FROM   x1
                              LEFT JOIN x2 using(date)
                              LEFT JOIN x5 using(date))
SELECT date,
       orders,
       first_orders,
       new_users_orders,
       round(100*(first_orders::decimal/ orders), 2) as first_orders_share,
       round(100*(new_users_orders::decimal/ orders), 2) as new_users_orders_share
FROM   x6
GROUP BY date, orders, first_orders, new_users_orders
ORDER BY date
