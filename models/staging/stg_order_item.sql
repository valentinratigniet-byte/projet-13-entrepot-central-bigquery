select order_id, product_id, quantity, unit_price
from {{ source('raw', 'order_item') }}
