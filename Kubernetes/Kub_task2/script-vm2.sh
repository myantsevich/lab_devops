#!/bin/bash

sudo -i

apt-get update 
apt-get install docker-ce docker-ce-cli containerd.io
systemctl enable docker && systemctl start docker
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system


apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sleep 10

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
# systemctl enable kubelet && systemctl start kubelet

sleep 120
kubeadm join 10.13.1.21:6443 --token o33jq9.qpyibih39bh0dzcq --discovery-token-unsafe-skip-ca-verification
