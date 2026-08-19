"""
Extraction + chargement : PostgreSQL (Projet 07, ecommerce) -> BigQuery (raw).
Rejouable (dlt gère l'idempotence en mode replace par défaut).

Prérequis : GOOGLE_APPLICATION_CREDENTIALS pointant vers la clé du compte de
service (~/.gcp/dbt-loader.json), conteneur Docker p07_ecommerce_db démarré.

Usage : python src/load_postgres_to_bq.py
"""
import dlt
from dlt.sources.sql_database import sql_database

PG_DSN = "postgresql://portfolio:portfolio@127.0.0.1:5433/ecommerce"


def main() -> None:
    pipeline = dlt.pipeline(
        pipeline_name="p07_to_bq",
        destination=dlt.destinations.bigquery(location="EU"),  # datasets crees en EU
        dataset_name="raw",
    )
    # Tables chargees telles quelles (customer, orders, ...) : source unique
    # pour l'instant, un prefixe ne serait utile qu'avec plusieurs bases.
    source = sql_database(PG_DSN, schema="public")
    info = pipeline.run(source, write_disposition="replace")
    print(info)


if __name__ == "__main__":
    main()
