/* Задача 2.
Анализируя динамику показателей из предыдущего задания, вы могли заметить, что сравнивать абсолютные значения не очень удобно. 
Давайте посчитаем динамику показателей в относительных величинах.

Задание:
Дополните запрос из предыдущего задания и теперь для каждого дня, представленного в таблицах user_actions и courier_actions, 
дополнительно рассчитайте следующие показатели:

Прирост числа новых пользователей.
Прирост числа новых курьеров.
Прирост общего числа пользователей.
Прирост общего числа курьеров.
Показатели, рассчитанные на предыдущем шаге, также включите в результирующую таблицу.

Колонки с новыми показателями назовите соответственно new_users_change, new_couriers_change, total_users_growth, 
total_couriers_growth. Колонку с датами назовите date.
Все показатели прироста считайте в процентах относительно значений в предыдущий день. 
При расчёте показателей округляйте значения до двух знаков после запятой.
Результирующая таблица должна быть отсортирована по возрастанию даты.
Поля в результирующей таблице: date, new_users, new_couriers, total_users, total_couriers, new_users_change, new_couriers_change, 
total_users_growth, total_couriers_growth
*/ 
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
                                 LEFT JOIN x2 using(date)), x4 as (SELECT date,
                                             count(distinct user_id) as new_users,
                                             count(distinct courier_id) as new_couriers,
                                             sum(count(distinct user_id)) OVER(ORDER BY date)::integer as total_users,
                                             sum(count(distinct courier_id)) OVER(ORDER BY date)::integer as total_couriers
                                      FROM   x3
                                      GROUP BY date)
SELECT date,
       new_users,
       new_couriers,
       total_users,
       total_couriers,
       round((new_users/lag(new_users, 1) OVER ()::decimal - 1) * 100,
             2) as new_users_change,
       round((new_couriers/lag(new_couriers, 1) OVER ()::decimal - 1) * 100,
             2) as new_couriers_change,
       round((total_users/lag(total_users, 1) OVER ()::decimal - 1) * 100,
             2) as total_users_growth,
       round((total_couriers/lag(total_couriers, 1) OVER ()::decimal - 1) * 100,
             2) as total_couriers_growth
FROM   x4
