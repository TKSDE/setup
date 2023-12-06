#!/bin/bash

# Update package list and install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https

# Install Docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Add Kubernetes repository and install Kubernetes tools
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni

# Initialize the master node
sudo kubeadm init

# Configure kubectl for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply necessary network plugin
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Print the join command for worker nodes
echo "Copy and run the following command on worker nodes:"
sudo kubeadm token create --print-join-command

# Verify nodes on the master
echo "Run the following command on the master to verify nodes:"
echo "kubectl get nodes"

