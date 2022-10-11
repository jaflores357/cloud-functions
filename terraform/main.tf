
module "create_functions" {
  source      = "./functions"
  for_each    = toset(["add-cluster", "del-cluster", "list-cluster"])
  function    = each.key
  region      = var.region
  bucket_name = google_storage_bucket.function_bucket.name
}

resource "google_api_gateway_api" "api_gw" {
  provider     = google-beta
  project      = var.project_id
  api_id       = "clusters-api"
  display_name = "Clusters API Gateway"
}

resource "google_service_account" "clusters-api" {
  account_id   = "clusters-api-sa"
  display_name = "Cluster API Service Account"
}

resource "google_project_iam_member" "clusters-api-role" {
  project = var.project_id
  role    = "roles/apigateway.admin"
  member  = "serviceAccount:${google_service_account.clusters-api.email}"
}

resource "google_project_iam_member" "clusters-api-cloudrun" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.clusters-api.email}"
}

resource "google_project_iam_member" "clusters-api-cloudfunctions" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.clusters-api.email}"
}


resource "google_api_gateway_api_config" "api_cfg" {
  provider      = google-beta
  project       = var.project_id
  api           = google_api_gateway_api.api_gw.api_id
  api_config_id = "clusters-api-config"
  display_name  = "Cluste API Config"

  lifecycle {
    create_before_destroy = true
  }

  gateway_config {
    backend_config {
      google_service_account = google_service_account.clusters-api.email
    }
  }

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = base64encode(
        yamlencode(
          {
            swagger : "2.0"
            info : {
              title : "Clusters API"
              description : "API to get cluster Clusters info"
              version : "1.0.0"
            }
            schemes : ["https"]
            produces : ["application/json"]
            securityDefinitions : {
              api_key : {
                type : "apiKey"
                name : "key"
                in : "query"
              }
            },
            security : [
              { api_key : [] }
            ]
            paths : {
              "/clusters" : {
                post : {
                  summary : "Add new Cluster"
                  operationId : "addCluster"
                  x-google-backend : {
                    address : module.create_functions["add-cluster"].function-uri
                  }
                  responses : {
                    200 : {
                      description : "Cluster registered succesfully"
                      schema : {
                        type : "string"
                      }
                    }
                  },
                  security : [
                    { api_key : [] }
                  ]
                },
                get : {
                  summary : "List Clusters"
                  operationId : "listCluster"
                  x-google-backend : {
                    address : module.create_functions["list-cluster"].function-uri
                  }
                  responses : {
                    200 : {
                      description : "List Cluster succesfully"
                      schema : {
                        type : "string"
                      }
                    }
                  },
                  security : [
                    { api_key : [] }
                  ]
                },
                delete : {
                  summary : "Delete Cluster"
                  operationId : "deleteCluster"
                  x-google-backend : {
                    address : module.create_functions["del-cluster"].function-uri
                  }
                  responses : {
                    200 : {
                      description : "List Cluster succesfully"
                      schema : {
                        type : "string"
                      }
                    }
                  },
                  security : [
                    { api_key : [] }
                  ]
                }
              }
            }
          }
        )
      )
    }
  }
}

resource "google_project_service" "cluster-api" {
  project = var.project_id
  service = google_api_gateway_api.api_gw.managed_service
  depends_on = [
    google_api_gateway_api_config.api_cfg
  ]
}

resource "google_api_gateway_gateway" "gw" {
  provider = google-beta
  project  = var.project_id
  region   = var.region

  api_config = google_api_gateway_api_config.api_cfg.id

  gateway_id   = "clusters-api-gw"
  display_name = "Clusters API Gateway"

  depends_on = [
    google_project_service.cluster-api
  ]
}

# resource "google_apikeys_key" "clusters-key" {
#   name         = "clusters-key"
#   display_name = "Cluster API Key"
#   project      = var.project_id

# }