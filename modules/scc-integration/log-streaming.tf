# Copyright 2023 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

################################################## 
#
#             EventArc trigger SA
#
##################################################
# Create service account for pubsub to impersonate
resource "google_service_account" "event_arc_sub_sa" {
  account_id   = "gke2scc-ea-${local.random_id}"
  display_name = "Service account for Eventarc triggers"
}

# Grant above SA ability to invoke Cloud Run service (Cloud Functions v2)
resource "google_project_iam_member" "event_arc_sub_sa" {
  for_each = toset(["roles/run.invoker", "roles/eventarc.eventReceiver"])

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.event_arc_sub_sa.email}"
}

# Ensure pubsub service identity exists
resource "google_project_service_identity" "pubsub" {
  provider = google-beta

  project = local.project_id
  service = "pubsub.googleapis.com"
}

# Grant pubsub service identity ability to impersonate service accounts
resource "google_project_iam_member" "pubsub_sa" {
  for_each = toset(["roles/iam.serviceAccountTokenCreator"])

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_project_service_identity.pubsub.email}"
}

resource "google_pubsub_topic" "log_streaming" {

  name = "gke-2-scc-log-streaming-${local.random_id}"
}

resource "google_logging_organization_sink" "gke_events" {
  name        = "gke-2-scc-log-streaming-${local.random_id}"
  description = "Logging Sink used to stream k8s.io events into Security Command Center"

  org_id           = var.organization_id
  include_children = true

  destination = "pubsub.googleapis.com/${google_pubsub_topic.log_streaming.id}"

  filter = var.log_streaming_filter
}

resource "google_project_iam_member" "logging_sa" {
  for_each = toset(["roles/pubsub.publisher"])

  project = local.project_id
  role    = each.value
  member  = google_logging_organization_sink.gke_events.writer_identity
}

resource "google_eventarc_trigger" "gke-cp-events" {

  name            = "gke-to-scc-${local.random_id}"
  location        = local.region
  service_account = split(":", values(google_project_iam_member.event_arc_sub_sa)[0].member)[1]

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }

  transport {
    pubsub {
      topic = google_pubsub_topic.log_streaming.id
    }
  }

  # Since Cloud Functions v2 is powered by Cloud Run, we can target/invoke the GCF as a Cloud Run services
  destination {
    cloud_run_service {
      region  = google_cloudfunctions2_function.gke_2_scc_func.location
      service = google_cloudfunctions2_function.gke_2_scc_func.name
    }
  }
}