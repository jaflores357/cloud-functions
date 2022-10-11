# Clusters API

Cluster API is a Google Python Function for managing information of all clusters

It is secured by Google API Gateway with apiKey

All information is saved in Firestore in the same Google project

## How to use

Terraform inside terraform folder builds the functions and creates all resources

The source code is inside src folder and is separated by function

Change a function will trigger terraform to rebuild them

New functions must have a new folder inside src folder and must be referenced in create_functions module and added to the Gateway API config


# create_functions module 

```
module "create_functions" {
  source = "./functions"
  for_each = toset(["add-cluster", "del-cluster", "list-cluster","<FUNCTION>"])
  function = each.key
  region = var.region  
  bucket_name = google_storage_bucket.function_bucket.name
}
```


# API Gateway config to add:

```
<method> : {
    summary : "New function Clusters"
    operationId : "newFunctionCluster"
    x-google-backend : {
    address : module.create_functions["<FUNCTION>"].function-uri
    }
    responses : {
    200 : {
        description : "All good in the hood!"
        schema : {
        type : "string"
        }
    }
    },
    security : [
    { api_key : [] }
    ]
}
```

## Usage

# List clusters

```
curl -X GET https://<api>?key=<APIKEY>
curl -X GET https://<api>?key=<APIKEY>&name=<NAME>
```

# Add clusters

```
curl -X POST https://<api>?key=<APIKEY> -d {
  "name": "cluster-aws",
  "cluster_name": "br-cluster-aws-1",
  "project_zone": "southamerica-east1",
  "project_name": "clusters-admin",
  "cluster_cloud": "aws",
  "environments": ["test", "prod"],
  "zones": ["a", "b", "c"]
}
```

# Delete cluster

```
curl -X DELETE https://<api>?key=<APIKEY>&name=<NAME>
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)