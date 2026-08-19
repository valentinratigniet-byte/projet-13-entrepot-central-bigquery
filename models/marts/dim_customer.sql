-- Une ligne par client. Reprend le modele du Projet 09 (dim_customer).
select
    c.id                                as customer_key,
    c.email,
    concat(c.first_name, ' ', c.last_name) as full_name,
    c.country,
    coalesce(n.name_fr, c.country)     as country_name
from {{ ref('stg_customer') }} c
left join {{ ref('stg_country_names') }} n on n.code = c.country
