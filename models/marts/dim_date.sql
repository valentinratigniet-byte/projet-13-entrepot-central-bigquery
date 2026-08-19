-- Table calendrier, une ligne par jour couvrant l'historique des commandes.
-- BigQuery : EXTRACT(DAYOFWEEK ...) renvoie 1=dimanche .. 7=samedi (pas ISO).
with bornes as (
    select date(min(order_date)) as d_min, date(max(order_date)) as d_max
    from {{ ref('stg_orders') }}
),
jours as (
    select jour
    from bornes, unnest(generate_date_array(d_min, d_max, interval 1 day)) as jour
)
select
    cast(format_date('%Y%m%d', jour) as int64)          as date_key,
    jour                                                 as date,
    extract(year from jour)                              as annee,
    extract(quarter from jour)                            as trimestre,
    extract(month from jour)                              as mois_num,
    case extract(month from jour)
        when 1 then 'Janvier' when 2 then 'Février' when 3 then 'Mars'
        when 4 then 'Avril' when 5 then 'Mai' when 6 then 'Juin'
        when 7 then 'Juillet' when 8 then 'Août' when 9 then 'Septembre'
        when 10 then 'Octobre' when 11 then 'Novembre' when 12 then 'Décembre'
    end                                                   as mois_nom,
    format_date('%Y-%m', jour)                            as annee_mois,
    extract(day from jour)                                as jour,
    extract(dayofweek from jour)                          as jour_semaine_num,
    case extract(dayofweek from jour)
        when 1 then 'Dimanche' when 2 then 'Lundi' when 3 then 'Mardi'
        when 4 then 'Mercredi' when 5 then 'Jeudi' when 6 then 'Vendredi'
        when 7 then 'Samedi'
    end                                                   as jour_semaine_nom,
    extract(dayofweek from jour) in (1, 7)                as est_weekend
from jours
