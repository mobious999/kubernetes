#!/bin/bash

# Detect if this is a master or worker node
if [ "$1" == "master" ]; then
    echo "Setting up Kubernetes Master Node..."
    NODE_TYPE="master"
else
    echo "Setting up Kubernetes Worker Node..."
    NODE_TYPE="worker"
fi

# Update system and install dependencies
echo "Updating and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
echo "Installing Docker..."
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl enable docker
sudo systemctl start docker

# Install Kubernetes components
echo "Installing kubeadm, kubelet, kubectl..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update
sudo apt install -y kubeadm kubelet kubectl
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Disable swap (required by Kubernetes)
echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Set up networking (using a Flannel network plugin)
if [ "$NODE_TYPE" == "master" ]; then
    echo "Initializing Kubernetes Master Node..."
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16  # Flannel CIDR for pod network

    # Set up kubeconfig for kubectl
    echo "Setting up kubectl configuration..."
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Install Flannel for pod networking
    echo "Installing Flannel for pod networking..."
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

    # Display the join command for worker and additional master nodes
    echo "Kubeadm join command for worker nodes:"
    kubeadm token create --print-join-command
else
    # Join the worker node to the cluster using the join command from master node
    echo "Joining worker node to the cluster..."
    sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

    # Verify worker node joined the cluster
    echo "Verifying worker node..."
    kubectl get nodes
fi
