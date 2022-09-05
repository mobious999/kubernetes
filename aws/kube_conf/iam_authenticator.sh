#!/bin/bash
read -r -d '' KUBECONFIG <<EOF
apiVersion: v1
clusters:
- cluster:
    server: $cluster_endpoint
    certificate-authority-data: $certificate_data
  name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
contexts:
- context:
    cluster: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
    user: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
  name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
current-context: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
kind: Config
preferences: {}
users:
- name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "$cluster_name"
        # - "- --role-arn"
        # - "arn:aws:iam::$account_id:role/my-role"
      # env:
        # - name: "AWS_PROFILE"
        #   value: "aws-profile"
EOF
echo "${KUBECONFIG}" > ~/.kube/config