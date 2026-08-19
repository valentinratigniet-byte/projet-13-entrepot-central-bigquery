# Architecture — Entrepôt central BigQuery

## Infra GCP

| Élément | Valeur |
|---|---|
| Projet GCP | `portfolio-data-vr` |
| Facturation | Activée, liée au compte de facturation existant — reste dans le free tier (10 Go stockage + 1 To requêtes/mois gratuits ; volumes de ce projet largement en dessous) |
| Datasets | `raw`, `staging`, `marts` — région **EU** |
| Compte de service | `dbt-loader@portfolio-data-vr.iam.gserviceaccount.com` |
| Rôles IAM | `roles/bigquery.dataEditor` + `roles/bigquery.jobUser` (pas Owner — privilège minimal) |
| Clé de service | `~/.gcp/dbt-loader.json` (hors repo, jamais committée) |
| Authentification locale | `gcloud auth login` (compte utilisateur) + `GOOGLE_APPLICATION_CREDENTIALS` (compte de service, utilisé par dlt/dbt) |

## Garde-fous de coûts

- Aucun `SELECT *` dans les modèles marts — colonnes explicites.
- `staging` matérialisé en **vues** (pas de stockage, recalculé à la demande) ;
  `marts` matérialisé en **tables** (stocké une fois, lu par Power BI sans
  retraiter `staging` à chaque requête).
- Datasets en région unique (EU) pour éviter les frais de requêtes
  inter-régions.
- Pas de partitionnement/clustering pour l'instant — volumes (< 6 Mio scannés
  par `dbt run` complet) trop faibles pour que ça change quoi que ce soit au
  coût ; à ajouter si le volume grossit significativement.

## Incident notable : certificats SSL

Sur cette machine, un logiciel de sécurité local intercepte le trafic HTTPS
avec son propre certificat racine — celui-ci est approuvé par Windows mais
pas par les bundles de certificats par défaut de Python (`certifi`). Ça a
cassé successivement : l'installeur `gcloud`, `gcloud auth login`, et le
chargement `dlt` vers BigQuery (chacun avec un client HTTP différent).

**Fixes appliqués :**
1. Installeur `gcloud` : contourné en exécutant `bin/bootstrapping/install.py`
   avec le Python système (qui a `pip-system-certs`) plutôt que le Python
   embarqué de l'installeur.
2. `gcloud auth login` : bundle de certificats combiné généré depuis le
   magasin Windows (`Cert:\LocalMachine\Root` etc.) + `certifi`, pointé via
   `gcloud config set core/custom_ca_certs_file`.
3. `dlt` (venv du projet) : `pip install pip-system-certs` dans le venv —
   celui-ci patche `ssl` pour utiliser le magasin Windows automatiquement.

Si tu reproduis ce projet sur une machine sans interception SSL (la plupart
des machines perso), aucun de ces contournements n'est nécessaire.

## Definition of Done

- [x] La base Postgres du Projet 07 remonte dans `raw` via `dlt` (rejouable)
- [x] dbt produit `staging` + `marts` (étoile) avec 12/12 tests au vert
- [x] Lignage `dbt docs` généré (`dbt docs serve` en local)
- [x] Power BI branché sur `marts` — modèle en étoile, 3 relations, table de
      dates, 17 mesures DAX, documentation in-situ (tables/colonnes/mesures)
