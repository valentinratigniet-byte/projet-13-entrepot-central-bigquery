# Ressources créées à la main avant Terraform : importées dans l'état au premier apply, sans rien modifier.
locals {
  p = "portfolio-data-vr"
}

import {
  to = google_project_service.bigquery
  id = "${local.p}/bigquery.googleapis.com"
}

import {
  for_each = local.datasets
  to       = google_bigquery_dataset.this[each.key]
  id       = "projects/${local.p}/datasets/${each.key}"
}

import {
  to = google_service_account.dbt_loader
  id = "projects/${local.p}/serviceAccounts/dbt-loader@${local.p}.iam.gserviceaccount.com"
}

import {
  to = google_service_account.ci_dbt
  id = "projects/${local.p}/serviceAccounts/ci-dbt@${local.p}.iam.gserviceaccount.com"
}

import {
  to = google_project_iam_member.loader_data_editor
  id = "${local.p} roles/bigquery.dataEditor serviceAccount:dbt-loader@${local.p}.iam.gserviceaccount.com"
}

import {
  for_each = toset(["dbt_loader", "ci_dbt"])
  to       = google_project_iam_member.job_user[each.key]
  id       = "${local.p} roles/bigquery.jobUser serviceAccount:${replace(each.key, "_", "-")}@${local.p}.iam.gserviceaccount.com"
}
