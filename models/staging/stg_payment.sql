select id, order_id, amount, method, paid_at
from {{ source('raw', 'payment') }}
