aws eks create-nodegroup \
 --cli-input-json '
{
  "clusterName": "my-cluster",
  ...
  "taints": [
     {
         "key": "dedicated",
         "value": "gpuGroup",
         "effect": "NO_SCHEDULE"
     }
   ],
}'