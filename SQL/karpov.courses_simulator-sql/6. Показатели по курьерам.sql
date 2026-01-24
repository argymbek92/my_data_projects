/* Задача 6.
Теперь давайте попробуем примерно оценить нагрузку на наших курьеров и узнаем, сколько 
в среднем заказов и пользователей приходится на каждого из них.

Задание:
На основе данных в таблицах user_actions, courier_actions и orders для каждого дня 
рассчитайте следующие показатели:

Число платящих пользователей на одного активного курьера.
Число заказов на одного активного курьера.
Колонки с показателями назовите соответственно users_per_courier и orders_per_courier. 
Колонку с датами назовите date. При расчёте показателей округляйте значения до двух знаков после запятой.

Результирующая таблица должна быть отсортирована по возрастанию даты. 
Поля в результирующей таблице: date, users_per_courier, orders_per_courier */
with x1 as (SELECT time::date as date,
                   count(distinct user_id) as paying_users
            FROM   user_actions
            WHERE  order_id not in (SELECT order_id
                                    FROM   user_actions
                                    WHERE  action = 'cancel_order')
            GROUP BY time::date
            ORDER BY time::date), x2 as (SELECT time::date as date,
                                    count(distinct courier_id) as active_couriers
                             FROM   courier_actions
                             WHERE  order_id in (SELECT order_id
                                                 FROM   courier_actions
                                                 WHERE  action = 'deliver_order')
                             GROUP BY time::date), x3 as (SELECT date,
                                    paying_users,
                                    active_couriers
                             FROM   x1
                                 LEFT JOIN x2 using(date)), t1 as (SELECT min(time)::date as date,
                                             user_id
                                      FROM   user_actions
                                      WHERE  order_id in (SELECT order_id
                                                          FROM   user_actions
                                                          WHERE  action != 'cancel_order')
                                      GROUP BY user_id), t2 as (SELECT courier_id,
                                 min(time)::date as date
                          FROM   courier_actions
                          WHERE  order_id in (SELECT order_id
                                              FROM   user_actions
                                              WHERE  action != 'cancel_order')
                          GROUP BY courier_id), t3 as (SELECT date,
                                    user_id,
                                    courier_id
                             FROM   t1
                                 LEFT JOIN t2 using(date)), t4 as (SELECT date,
                                             count(distinct user_id) as new_users,
                                             count(distinct courier_id) as new_couriers
                                      FROM   t3
                                      GROUP BY date), t5 as (SELECT creation_time::date as date,
                              count(distinct order_id) as orders
                       FROM   orders
                       WHERE  order_id in (SELECT order_id
                                           FROM   courier_actions
                                           WHERE  action = 'deliver_order')
                       GROUP BY creation_time::date)
SELECT date,
       round(paying_users/active_couriers::decimal, 2) as users_per_courier,
       round(orders/active_couriers::decimal, 2) as orders_per_courier
FROM   x3
    LEFT JOIN t4 using(date)
    LEFT JOIN t5 using(date)
ORDER BY date
