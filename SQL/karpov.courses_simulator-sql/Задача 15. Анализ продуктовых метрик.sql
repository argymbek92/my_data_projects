/* Задача 7.*
Теперь попробуем учесть в наших расчётах затраты с налогами и посчитаем валовую прибыль, то есть ту сумму, которую мы фактически получили в результате реализации 
товаров за рассматриваемый период.

Задание:
Для каждого дня в таблицах orders и courier_actions рассчитайте следующие показатели:

Выручку, полученную в этот день.
Затраты, образовавшиеся в этот день.
Сумму НДС с продажи товаров в этот день.
Валовую прибыль в этот день (выручка за вычетом затрат и НДС).
Суммарную выручку на текущий день.
Суммарные затраты на текущий день.
Суммарный НДС на текущий день.
Суммарную валовую прибыль на текущий день.
Долю валовой прибыли в выручке за этот день (долю п.4 в п.1).
Долю суммарной валовой прибыли в суммарной выручке на текущий день (долю п.8 в п.5).
Колонки с показателями назовите соответственно revenue, costs, tax, gross_profit, total_revenue, total_costs, total_tax, total_gross_profit, gross_profit_ratio, total_gross_profit_ratio

~ Колонку с датами назовите date.
~ Долю валовой прибыли в выручке необходимо выразить в процентах, округлив значения до двух знаков после запятой.
~ Результат должен быть отсортирован по возрастанию даты.
~ Поля в результирующей таблице: date, revenue, costs, tax, gross_profit, total_revenue, total_costs, total_tax, total_gross_profit, gross_profit_ratio, total_gross_profit_ratio
Чтобы посчитать затраты, в этой задаче введём дополнительные условия.
~ В упрощённом виде затраты нашего сервиса будем считать как сумму постоянных и переменных издержек. К постоянным издержкам отнесём аренду складских помещений, 
а к переменным — стоимость сборки и доставки заказа. Таким образом, переменные затраты будут напрямую зависеть от числа заказов.
~ Из данных, которые нам предоставил финансовый отдел, известно, что в августе 2022 года постоянные затраты составляли 120 000 рублей в день. Однако уже в сентябре 
нашему сервису потребовались дополнительные помещения, и поэтому постоянные затраты возросли до 150 000 рублей в день.
~ Также известно, что в августе 2022 года сборка одного заказа обходилась нам в 140 рублей, при этом курьерам мы платили по 150 рублей за один доставленный заказ 
и ещё 400 рублей ежедневно в качестве бонуса, если курьер доставлял не менее 5 заказов в день. В сентябре продакт-менеджерам удалось снизить затраты на сборку 
заказа до 115 рублей, но при этом пришлось повысить бонусную выплату за доставку 5 и более заказов до 500 рублей, чтобы обеспечить более конкурентоспособные 
условия труда. При этом в сентябре выплата курьерам за один доставленный заказ осталась неизменной.

Пояснение: 
При расчёте переменных затрат учитывайте следующие условия:
1. Затраты на сборку учитываются в том же дне, когда был оформлен заказ. Сборка отменённых заказов не производится.
2. Выплата курьерам за доставленный заказ начисляется сразу же после его доставки, поэтому если курьер доставит заказ на следующий день, то и выплата будет учтена в следующем дне.
3. Для получения бонусной выплаты курьерам необходимо доставить не менее 5 заказов в течение одного дня, поэтому если курьер примет 5 заказов в течение дня, но последний из них 
доставит после полуночи, бонусную выплату он не получит.

При расчёте НДС учитывайте, что для некоторых товаров налог составляет 10%, а не 20%. Список товаров со сниженным НДС:
'сахар', 'сухарики', 'сушки', 'семечки', 'масло льняное', 'виноград', 'масло оливковое', 'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 
'овсянка', 'макароны', 'баранина', 'апельсины', 'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 
'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины'

Также при расчёте величины НДС по каждому товару округляйте значения до двух знаков после запятой.
При расчёте выручки по-прежнему будем считать, что оплата за заказ поступает сразу же после его оформления, т.е. случаи, когда заказ был оформлен в один день, а оплата получена на следующий, возникнуть не могут.
Также помните, что не все заказы были оплачены — некоторые были отменены пользователями.
*/
with x1 as (SELECT date (time) as date,
                   courier_id,
                   count (order_id) filter (WHERE action = 'deliver_order') as delivery_orders,
                   count (order_id) filter (WHERE action = 'accept_order') as accepted_orders
            FROM   courier_actions
            WHERE  order_id not in (SELECT order_id
                                    FROM   user_actions
                                    WHERE  action = 'cancel_order')
            GROUP BY date, courier_id), x2 as (SELECT date,
                                          courier_id,
                                          delivery_orders,
                                          accepted_orders,
                                          case when date_part ('month', date) = 8 and
                                                    date_part ('year', date) = 2022 then accepted_orders*140
                                               else accepted_orders*115 end as order_assembly_costs,
                                          delivery_orders*150 as delivery_order_costs,
                                          case when date_part ('month', date) = 8 and
                                                    date_part ('year', date) = 2022 and
                                                    delivery_orders >= 5 then 400
                                               when date_part ('month', date) = 9 and
                                                    date_part ('year', date) = 2022 and
                                                    delivery_orders >= 5 then 500
                                               else 0 end as delivery_orders_bonus
                                   FROM   x1), x3 as (SELECT date,
                          case when date_part ('month', date) = 8 and
                                    date_part ('year', date) = 2022 then 120000 + sum (order_assembly_costs) + sum (delivery_order_costs) + sum (delivery_orders_bonus)
                               else 150000 + sum (order_assembly_costs) + sum (delivery_order_costs) + sum (delivery_orders_bonus) end as costs
                   FROM   x2
                   GROUP BY date), x4 as (SELECT date(creation_time) as date,
                              order_id,
                              unnest(product_ids) as product_id
                       FROM   orders
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')), x5 as (SELECT date,
                                                order_id,
                                                name,
                                                price,
                                                case when name in ('сахар', 'сухарики', 'сушки', 'семечки', 'масло льняное', 'виноград',
                                                                   'масло оливковое', 'арбуз', 'батон', 'йогурт', 'сливки',
                                                                   'гречка', 'овсянка', 'макароны', 'баранина', 'апельсины',
                                                                   'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 'мука',
                                                                   'шпроты', 'сосиски', 'свинина', 'рис', 'масло кунжутное',
                                                                   'сгущенка', 'ананас', 'говядина', 'соль', 'рыба вяленая',
                                                                   'масло подсолнечное', 'яблоки', 'груши', 'лепешка', 'молоко',
                                                                   'курица', 'лаваш', 'вафли', 'мандарины') then round (price*10/110, 2)
                                                     else round (price*20/120, 2) end as product_tax
                                         FROM   x4
                                             LEFT JOIN products using (product_id)), x6 as (SELECT date,
                                                          sum(price) as revenue,
                                                          sum(product_tax) as tax
                                                   FROM   x5
                                                   GROUP BY date
                                                   ORDER BY date)
SELECT date,
       revenue,
       costs,
       tax,
       revenue - costs - tax as gross_profit,
       sum (revenue) OVER (ORDER BY date) as total_revenue,
       sum (costs) OVER (ORDER BY date) as total_costs,
       sum (tax) OVER (ORDER BY date) as total_tax,
       sum (revenue - costs - tax) OVER (ORDER BY date) as total_gross_profit,
       round (100*(revenue - costs - tax)/revenue::decimal, 2) as gross_profit_ratio,
       round (100*sum (revenue - costs - tax) OVER (ORDER BY date)/sum (revenue) OVER (ORDER BY date)::decimal, 2) as total_gross_profit_ratio
FROM   x6
    LEFT JOIN x3 using (date)
ORDER BY date
