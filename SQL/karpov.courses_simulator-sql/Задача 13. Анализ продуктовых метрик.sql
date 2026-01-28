/* Задача 5.*
Немного усложним наш первоначальный запрос и отдельно посчитаем ежедневную выручку с заказов новых пользователей нашего сервиса. Посмотрим, какую долю она составляет в общей выручке с заказов всех пользователей — и новых, и старых.

Задание:
Для каждого дня в таблицах orders и user_actions рассчитайте следующие показатели:

Выручку, полученную в этот день.
Выручку с заказов новых пользователей, полученную в этот день.
Долю выручки с заказов новых пользователей в общей выручке, полученной за этот день.
Долю выручки с заказов остальных пользователей в общей выручке, полученной за этот день.
Колонки с показателями назовите соответственно revenue, new_users_revenue, new_users_revenue_share, old_users_revenue_share. Колонку с датами назовите date. 

Все показатели долей необходимо выразить в процентах. При их расчёте округляйте значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, revenue, new_users_revenue, new_users_revenue_share, old_users_revenue_share */
with main_t as(SELECT date,
                      user_id,
                      order_id,
                      order_price
               FROM   (SELECT date(time) as date,
                              user_id,
                              order_id
                       FROM   user_actions
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')) as t1
                   LEFT JOIN (SELECT order_id,
                                     sum(price) as order_price
                              FROM   (SELECT order_id,
                                             unnest (product_ids) as product_id
                                      FROM   orders) t1
                                  LEFT JOIN products using (product_id)
                              GROUP BY order_id) as t2 using (order_id)), new_users_revenue as(SELECT t3.date as date,
                                                                        sum (order_price) as new_users_revenue
                                                                 FROM   main_t
                                                                     RIGHT JOIN (SELECT date(min(time)) as date,
                                                                                        user_id
                                                                                 FROM   user_actions
                                                                                 GROUP BY user_id
                                                                                 ORDER BY user_id) t3
                                                                         ON main_t.date = t3.date and
                                                                            main_t.user_id = t3.user_id
                                                                 GROUP BY t3.date
                                                                 ORDER BY date)
SELECT date,
       revenue,
       new_users_revenue,
       round (100*new_users_revenue/revenue::decimal, 2) as new_users_revenue_share,
       100 - round (100*new_users_revenue/revenue::decimal, 2) as old_users_revenue_share
FROM   (SELECT date,
               sum (order_price) as revenue
        FROM   main_t
        GROUP BY date) as t4
    LEFT JOIN new_users_revenue using (date)
ORDER BY date
