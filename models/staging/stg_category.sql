select id, name, parent_id
from {{ source('raw', 'category') }}
