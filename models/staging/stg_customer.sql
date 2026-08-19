select id, email, first_name, last_name, country, created_at
from {{ source('raw', 'customer') }}
