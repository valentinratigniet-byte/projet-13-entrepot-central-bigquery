select id, sku, name, category_id, price, is_active, created_at
from {{ source('raw', 'product') }}
