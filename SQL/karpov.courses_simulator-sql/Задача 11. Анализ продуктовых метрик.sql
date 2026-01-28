/* Задача 3.*
Дополним наш анализ ещё более интересными расчётами — вычислим все те же метрики, но для каждого дня будем учитывать накопленную выручку и все имеющиеся на текущий момент данные о числе пользователей и заказов. Таким образом, получим динамический ARPU, ARPPU и AOV и сможем проследить, как он менялся на протяжении времени с учётом поступающих нам данных.

Задание:
По таблицам orders и user_actions для каждого дня рассчитайте следующие показатели:

Накопленную выручку на пользователя (Running ARPU).
Накопленную выручку на платящего пользователя (Running ARPPU).
Накопленную выручку с заказа, или средний чек (Running AOV).
Колонки с показателями назовите соответственно running_arpu, running_arppu, running_aov. Колонку с датами назовите date. 

При расчёте всех показателей округляйте значения до двух знаков после запятой. Результат должен быть отсортирован по возрастанию даты. 
Поля в результирующей таблице: date, running_arpu, running_arppu, running_aov */

--на дату вывести
--1.число всех пользователей уникальных
--2.число пользователей, которые совершили заказ и не отменили его
--3.число заказов, которые совершили платящие пользователи
--считаем показатели по платящим пользователям*/
with x1 as (SELECT creation_time::date as date,
                   order_id,
                   unnest(product_ids) as product_id
            FROM   orders), x2 as (SELECT date,
                              order_id,
                              product_id,
                              price,
                              user_id
                       FROM   x1
                           LEFT JOIN products using(product_id)
                           LEFT JOIN user_actions using(order_id)), x3 as (SELECT date,
                                                           count(distinct order_id) as orders,
                                                           sum(price) as revenue
                                                    FROM   x2
                                                    WHERE  order_id not in (SELECT order_id
                                                                            FROM   user_actions
                                                                            WHERE  action = 'cancel_order')
                                                    GROUP BY date
                                                    ORDER BY date), x4 as (SELECT date,
                              sum(count(distinct user_id)) OVER(ORDER BY date) as running_users_new
                       FROM   (SELECT min(time)::date as date,
                                      user_id
                               FROM   user_actions
                               WHERE  order_id not in (SELECT order_id
                                                       FROM   user_actions
                                                       WHERE  action = 'cancel_order')
                               GROUP BY user_id) t
                       GROUP BY date), x5 as (SELECT date,
                              sum(count (user_id)) OVER(ORDER BY date) as running_users
                       FROM   (SELECT user_id,
                                      min(time)::date as date
                               FROM   user_actions
                               GROUP BY user_id) t1
                       GROUP BY date), x6 as (SELECT date,
                              running_users,
                              orders,
                              running_users_new,
                              revenue
                       FROM   x3
                           LEFT JOIN x4 using(date)
                           LEFT JOIN x5 using(date))
SELECT date,
       round(sum(revenue) OVER(ORDER BY date)::decimal/running_users, 2) as running_arpu,
       round(sum(revenue) OVER(ORDER BY date)::decimal/running_users_new,
             2) as running_arppu,
       round(sum(revenue) OVER(ORDER BY date)::decimal/sum (orders) OVER (ORDER BY date rows unbounded preceding),
             2) as running_aov
FROM   x6
