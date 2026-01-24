/* Задача 7.
Давайте рассчитаем ещё один полезный показатель, характеризующий качество работы курьеров.

Задание:
На основе данных в таблице courier_actions для каждого дня рассчитайте, за сколько минут 
в среднем курьеры доставляли свои заказы.

Колонку с показателем назовите minutes_to_deliver. Колонку с датами назовите date. 
При расчёте среднего времени доставки округляйте количество минут до целых значений. 
Учитывайте только доставленные заказы, отменённые заказы не учитывайте.

Результирующая таблица должна быть отсортирована по возрастанию даты. 
Поля в результирующей таблице: date, minutes_to_deliver */
with t1 as (SELECT courier_id,
                   order_id,
                   time as time_delivered
            FROM   courier_actions
            WHERE  action = 'deliver_order'
               and order_id not in (SELECT order_id
                                 FROM   user_actions
                                 WHERE  action = 'cancel_order')), t2 as (SELECT courier_id,
                                                order_id,
                                                time as time_accepted
                                         FROM   courier_actions
                                         WHERE  action = 'accept_order'
                                            and order_id not in (SELECT order_id
                                                              FROM   user_actions
                                                              WHERE  action = 'cancel_order')), t3 as (SELECT courier_id,
                                                order_id,
                                                time_accepted,
                                                time_delivered,
                                                time_delivered - time_accepted as time_diff
                                         FROM   t2
                                             LEFT JOIN t1 using(courier_id, order_id))
SELECT time_accepted ::date as date,
       round(avg(extract(epoch
FROM   time_diff/60)))::integer as minutes_to_deliver
FROM   t3
GROUP BY time_accepted ::date
ORDER BY date
