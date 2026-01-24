/*Задача 8.
И наконец, давайте оценим почасовую нагрузку на наш сервис, выясним, в какие часы пользователи
оформляют больше всего заказов, и заодно проанализируем, как изменяется доля отмен в зависимости 
от времени оформления заказа.

Задача: На основе данных в таблице orders для каждого часа в сутках 
рассчитайте следующие показатели:

Число успешных (доставленных) заказов.
Число отменённых заказов.
Долю отменённых заказов в общем числе заказов (cancel rate).
Колонки с показателями назовите соответственно successful_orders, canceled_orders, cancel_rate. 
Колонку с часом оформления заказа назовите hour. При расчёте доли отменённых заказов 
округляйте значения до трёх знаков после запятой.

Результирующая таблица должна быть отсортирована по возрастанию колонки с часом оформления заказа.
Поля в результирующей таблице: hour, successful_orders, canceled_orders, cancel_rate */
SELECT date_part('hour', creation_time)::int as hour,
       count (order_id) filter(WHERE order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')) as successful_orders , count (order_id) filter(
WHERE  order_id in (SELECT order_id
                    FROM   user_actions
                    WHERE  action = 'cancel_order')) as canceled_orders, round(count (order_id) filter(
WHERE  order_id in (SELECT order_id
                    FROM   user_actions
                    WHERE  action = 'cancel_order'))/ count(order_id)::decimal, 3) as cancel_rate
FROM   orders
GROUP BY date_part('hour', creation_time)
