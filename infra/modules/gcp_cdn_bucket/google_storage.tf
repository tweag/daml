# Copyright (c) 2019 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

data "google_project" "current" {
  project_id = "${var.project}"
}

locals {
  default_role_entities = [
    "OWNER:project-owners-${data.google_project.current.number}",
    "OWNER:project-editors-${data.google_project.current.number}",
    "READER:project-viewers-${data.google_project.current.number}",

    # all the objects are publicly readable!
    "READER:allUsers",
  ]
}

resource "google_storage_bucket" "default" {
  project = "${var.project}"
  name    = "${var.name}"
  labels  = "${var.labels}"

  # SLA is enough for a cache and is cheaper than MULTI_REGIONAL
  # see https://cloud.google.com/storage/docs/storage-classes
  storage_class = "REGIONAL"

  # Use a normal region since the storage_class is regional
  location = "${var.region}"

  # cleanup the cache after 60 days
  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age = "${var.cache_retention_days}" # days
    }
  }

  website {
    main_page_suffix = "index.html"
  }

  force_destroy = true
}

resource "google_storage_bucket_acl" "default" {
  bucket      = "${google_storage_bucket.default.name}"
  default_acl = "publicread"
  role_entity = ["${local.default_role_entities}"]
}

resource "google_storage_bucket_object" "default" {
  name         = "index.html"
  bucket       = "${google_storage_bucket.default.name}"
  content      = "${file("${path.module}/files/index.html")}"
  content_type = "text/html"
  depends_on   = ["google_storage_bucket_acl.default"]
}
