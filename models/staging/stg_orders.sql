select id, customer_id, order_date, status
from {{ source('raw', 'orders') }}
