/* Задача 6.
Также было бы интересно посмотреть, какие товары пользуются наибольшим спросом и приносят нам основной доход.

Задание:
Для каждого товара, представленного в таблице products, за весь период времени в таблице orders рассчитайте следующие показатели:

Суммарную выручку, полученную от продажи этого товара за весь период.
Долю выручки от продажи этого товара в общей выручке, полученной за весь период.
Колонки с показателями назовите соответственно revenue и share_in_revenue. Колонку с наименованиями товаров назовите product_name.

Долю выручки с каждого товара необходимо выразить в процентах. При её расчёте округляйте значения до двух знаков после запятой.
Товары, округлённая доля которых в выручке составляет менее 0.5%, объедините в общую группу с названием «ДРУГОЕ» (без кавычек), просуммировав округлённые доли этих товаров.
Результат должен быть отсортирован по убыванию выручки от продажи товара.
Поля в результирующей таблице: product_name, revenue, share_in_revenue */
with x1 as (SELECT name,
                   price,
                   creation_time::date as date,
                   order_id
            FROM   products
                RIGHT JOIN (SELECT creation_time,
                                   order_id,
                                   unnest(product_ids) as product_id
                            FROM   orders) t1 using(product_id)
            WHERE  order_id not in (SELECT order_id
                                    FROM   user_actions
                                    WHERE  action = 'cancel_order')), x2 as (SELECT name as product_name,
                                                sum(price) as revenue
                                         FROM   x1
                                         GROUP BY name
                                         ORDER BY revenue desc), x3 as (SELECT product_name,
                                      revenue,
                                      round(100*(revenue::decimal/sum(revenue) OVER()), 2) as share_in_revenue
                               FROM   x2
                               ORDER BY revenue desc)
SELECT case when share_in_revenue < 0.5 then 'ДРУГОЕ'
            else product_name end as product_name,
       sum(revenue) as revenue,
       sum(share_in_revenue) as share_in_revenue
FROM   x3
GROUP BY case when share_in_revenue < 0.5 then 'ДРУГОЕ' else product_name end
ORDER BY revenue desc
