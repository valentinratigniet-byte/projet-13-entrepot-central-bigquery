# Dictionnaire de données (généré depuis le modèle Power BI)

Documentation in-situ : chaque table, colonne clé et mesure porte sa
description directement dans le modèle sémantique (visible dans le volet
Champs de Power BI). Ce fichier en est la synthèse.

## Tables

| Table | Description |
|---|---|
| `dim_customer` | Dimension client — une ligne par client. Nom complet et pays dénormalisés. |
| `dim_product` | Dimension produit — une ligne par produit, catégorie dénormalisée (étoile, pas flocon). |
| `dim_date` | Table calendrier (table de dates officielle) — une ligne par jour. Alimente la time intelligence. |
| `fct_sales` | Table de faits — grain = une ligne de commande. FK vers les 3 dimensions. |
| `_Mesures` | Table technique (vide) regroupant les 17 mesures DAX, organisées par dossier. |

## Colonnes clés

| Table | Colonne | Description |
|---|---|---|
| `dim_customer` | `customer_key` | Clé primaire client. |
| `dim_customer` | `country_name` | Nom du pays en français (jointure `country_names`, repli sur le code si absent). |
| `dim_product` | `product_key` | Clé primaire produit. |
| `dim_product` | `category` | Catégorie produit, dénormalisée. |
| `dim_date` | `date_key` | Clé date `YYYYMMDD` (correspond à `fct_sales[date_key]`). |
| `dim_date` | `annee_mois` | `YYYY-MM`, trié chronologiquement en texte. |
| `fct_sales` | `line_amount` | `quantity * unit_price` — mesure de base du CA. |
| `fct_sales` | `status` | Statut commande (`paid`, `shipped`, `delivered`, `cancelled`...). |

## Mesures (17, table `_Mesures`)

| Dossier | Mesure | Description |
|---|---|---|
| 1. Base | `CA` | Chiffre d'affaires total. |
| 1. Base | `CA validé` | CA restreint aux commandes payées/expédiées/livrées. |
| 1. Base | `Panier moyen` | CA / nombre de commandes distinctes. |
| 1. Base | `Nb commandes`, `Nb clients`, `Unités vendues` | Comptages de base. |
| 2. Time intelligence | `CA YTD` | Cumul depuis le début de l'année civile. |
| 2. Time intelligence | `Croissance YoY %` / `MoM %` | Variation vs même période l'an dernier / mois précédent. |
| 2. Time intelligence | `CA moyenne 3M` | Moyenne glissante 3 mois (lissage de tendance). |
| 3. Ratios | `% du total catégorie` | Part du CA dans le total, toutes catégories confondues. |
| 3. Ratios | `Rang produit` | Classement des produits par CA. |
| 3. Ratios | `Taux récurrence %` | Part des clients ayant passé plus d'une commande. |
| 4. Mise en forme | `Tendance YoY` | Indicateur ▲▼▬ selon la croissance annuelle. |

Détail complet des formules : [Projet 09 — dax/measures.md](../projet-09-dashboard-powerbi/dax/measures.md)
(mêmes mesures, même modèle en étoile).

## Relations

3 relations many-to-one, auto-détectées par Power BI et vérifiées :
`fct_sales[customer_key]` → `dim_customer[customer_key]`,
`fct_sales[product_key]` → `dim_product[product_key]`,
`fct_sales[date_key]` → `dim_date[date_key]`.
`dim_date` est marquée table de dates officielle (colonne `date`).
