#!/bin/bash

sudo -i

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system


apt-get update 
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sleep 10

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl


kubeadm init --token o33jq9.qpyibih39bh0dzcq 

# export KUBECONFIG=/etc/kubernetes/admin.conf


mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown 0:0 /root/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

sleep 500
kubectl label node vm-2 node-role.kubernetes.io/worker=
