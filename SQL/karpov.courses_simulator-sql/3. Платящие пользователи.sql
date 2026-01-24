/* Задача 3.
Теперь предлагаем вам посмотреть на нашу аудиторию немного под другим углом — давайте 
посчитаем не просто всех пользователей, а именно ту часть, которая оформляет и оплачивает 
заказы в нашем сервисе. Заодно выясним, какую долю платящие пользователи составляют от их 
общего числа.

Задание:
Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитайте 
следующие показатели:

Число платящих пользователей.
Число активных курьеров.
Долю платящих пользователей в общем числе пользователей на текущий день.
Долю активных курьеров в общем числе курьеров на текущий день.
Колонки с показателями назовите соответственно paying_users, active_couriers, paying_users_share, active_couriers_share. Колонку с датами назовите date. Проследите за тем, чтобы абсолютные показатели были выражены целыми числами. Все показатели долей необходимо выразить в процентах. При их расчёте округляйте значения до двух знаков после запятой.

Результат должен быть отсортирован по возрастанию даты. 
Поля в результирующей таблице: date, paying_users, active_couriers, paying_users_share, 
active_couriers_share */
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
                                             count(distinct courier_id) as new_couriers,
                                             sum(count(distinct user_id)) OVER(ORDER BY date)::integer as total_users,
                                             sum(count(distinct courier_id)) OVER(ORDER BY date)::integer as total_couriers
                                      FROM   t3
                                      GROUP BY date)
SELECT date,
       paying_users,
       active_couriers,
       round((paying_users/total_users::decimal)*100, 2) as paying_users_share,
       round((active_couriers/total_couriers::decimal)*100, 2) as active_couriers_share
FROM   x3
    LEFT JOIN t4 using(date)
ORDER BY date
