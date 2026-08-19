select code, name_fr
from {{ source('raw', 'country_names') }}
