-- Une ligne par produit, categorie denormalisee (etoile, pas flocon).
select
    p.id            as product_key,
    p.sku,
    p.name          as product_name,
    cat.name        as category,
    p.price,
    p.is_active
from {{ ref('stg_product') }} p
join {{ ref('stg_category') }} cat on cat.id = p.category_id
