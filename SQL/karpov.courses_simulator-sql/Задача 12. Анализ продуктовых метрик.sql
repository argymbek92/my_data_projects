/*Задача 4.
Давайте посчитаем те же показатели, но в другом разрезе — не просто по дням, а по дням недели.

Задание:
Для каждого дня недели в таблицах orders и user_actions рассчитайте следующие показатели:

Выручку на пользователя (ARPU).
Выручку на платящего пользователя (ARPPU).
Выручку на заказ (AOV).
При расчётах учитывайте данные только за период с 26 августа 2022 года по 8 сентября 2022 года включительно — так, чтобы в анализ попало одинаковое количество всех дней недели (ровно по два дня).

В результирующую таблицу включите как наименования дней недели (например, Monday), так и порядковый номер дня недели (от 1 до 7, где 1 — это Monday, 7 — это Sunday).
Колонки с показателями назовите соответственно arpu, arppu, aov. Колонку с наименованием дня недели назовите weekday, а колонку с порядковым номером дня недели weekday_number.
При расчёте всех показателей округляйте значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию порядкового номера дня недели.
Поля в результирующей таблице: weekday, weekday_number, arpu, arppu, aov */

--на день недели вывести
--1.число всех пользователей уникальных
--2.число пользователей, которые совершили заказ и не отменили его
--3.число заказов, которые совершили платящие пользователи 
with revenue as(SELECT weekday_number,
                       weekday,
                       sum (price) as revenue,
                       count(distinct order_id) as orders FROM(SELECT date_part ('isodow', creation_time) as weekday_number,
                                                               to_char (creation_time, 'Day') as weekday,
                                                               order_id,
                                                               unnest (product_ids) as product_id
                                                        FROM   orders
                                                        WHERE  order_id not in (SELECT order_id
                                                                                FROM   user_actions
                                                                                WHERE  action = 'cancel_order')
                                                           and creation_time between '2022-08-26'
                                                           and '2022-09-08 23:59:59') as t1
                    LEFT JOIN products using (product_id)
                GROUP BY weekday_number, weekday), users as(SELECT date_part ('isodow', time) as weekday_number,
                                                   count(distinct user_id) filter (WHERE order_id not in (SELECT order_id
                                                                                                   FROM   user_actions
                                                                                                   WHERE  action = 'cancel_order')) as paying_users, count(distinct user_id) as users
                                            FROM   user_actions
                                            WHERE  time between '2022-08-26'
                                               and '2022-09-08 23:59:59'
                                            GROUP BY weekday_number)
SELECT weekday,
       weekday_number,
       round (revenue::decimal/users, 2) as arpu,
       round (revenue::decimal/paying_users, 2) as arppu,
       round (revenue::decimal/orders, 2) as aov
FROM   revenue
    LEFT JOIN users using (weekday_number)
ORDER BY weekday_number
