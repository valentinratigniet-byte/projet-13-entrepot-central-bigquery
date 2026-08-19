-- Table de faits, grain = une ligne de commande. FK vers les 3 dimensions.
select
    o.id                                            as order_id,
    o.customer_id                                   as customer_key,
    oi.product_id                                    as product_key,
    cast(format_date('%Y%m%d', date(o.order_date)) as int64) as date_key,
    o.status,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price)                    as line_amount
from {{ ref('stg_orders') }} o
join {{ ref('stg_order_item') }} oi on oi.order_id = o.id
