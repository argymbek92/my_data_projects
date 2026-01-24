/* Задача 1.
Начнём с выручки — наиболее общего показателя, который покажет, какой доход приносит наш сервис.

Задание:
Для каждого дня в таблице orders рассчитайте следующие показатели:

Выручку, полученную в этот день.
Суммарную выручку на текущий день.
Прирост выручки, полученной в этот день, относительно значения выручки за предыдущий день.
Колонки с показателями назовите соответственно revenue, total_revenue, revenue_change. Колонку с датами назовите date.

Прирост выручки рассчитайте в процентах и округлите значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, revenue, total_revenue, revenue_change */
with x1 as (SELECT creation_time::date as date,
                   order_id,
                   unnest(product_ids) as product_id
            FROM   orders), x2 as (SELECT date,
                              order_id,
                              product_id,
                              name,
                              price
                       FROM   x1
                           LEFT JOIN products using(product_id)), x3 as (SELECT date,
                                                         round(sum(price), 1) as revenue
                                                  FROM   x2
                                                  WHERE  order_id not in (SELECT order_id
                                                                          FROM   user_actions
                                                                          WHERE  action = 'cancel_order')
                                                  GROUP BY date
                                                  ORDER BY date)
SELECT date,
       revenue,
       round(sum(revenue) OVER (rows between unbounded preceding and current row),
             1) as total_revenue,
       -- SUM (revenue) OVER (ORDER BY date) AS total_revenue,
       round (100*revenue::decimal/lag (revenue, 1) OVER () - 100, 2) as revenue_change
FROM   x3
