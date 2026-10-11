# Infrastructure GCP de l'entrepôt : décrite ici, importée depuis l'existant (imports.tf).
#   prod : raw ← dlt (dbt-loader) → staging → marts (dbt)
#   CI   : ci_raw → ci_staging → ci_marts, seuls datasets accessibles au compte ci-dbt

locals {
  # raw ← dlt ; staging, marts ← dbt ; ci_* : mêmes couches, recréées à chaque exécution de la CI
  datasets    = toset(["raw", "staging", "marts", "ci_raw", "ci_staging", "ci_marts"])
  ci_datasets = toset([for d in local.datasets : d if startswith(d, "ci_")])
}

resource "google_project_service" "bigquery" {
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

resource "google_bigquery_dataset" "this" {
  for_each   = local.datasets
  dataset_id = each.key
  location   = var.location

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role          = "OWNER"
    user_by_email = var.owner_email
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
  # Le compte de CI n'écrit que dans les datasets ci_*
  dynamic "access" {
    for_each = contains(local.ci_datasets, each.key) ? [1] : []
    content {
      role          = "WRITER"
      user_by_email = google_service_account.ci_dbt.email
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account" "dbt_loader" {
  account_id   = "dbt-loader"
  display_name = "dbt & dlt loader"
}

resource "google_service_account" "ci_dbt" {
  account_id   = "ci-dbt"
  display_name = "CI GitHub Actions (datasets ci_* uniquement)"
}

# Droits au niveau projet (non exclusifs : n'enlèvent rien à ce qui existe à côté)
resource "google_project_iam_member" "loader_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = google_service_account.dbt_loader.member
}

resource "google_project_iam_member" "job_user" {
  for_each = {
    dbt_loader = google_service_account.dbt_loader.member
    ci_dbt     = google_service_account.ci_dbt.member
  }
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = each.value
}

# Les clés des comptes de service ne sont PAS gérées ici : elles finiraient en clair dans l'état Terraform.
# Elles sont créées à la main (gcloud iam service-accounts keys create) et rangées hors dépôt / en secret GitHub.
