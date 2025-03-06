#!/bin/bash

# Desativar Swap Permanentemente
echo "[TASK 1] Desativando Swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Carregar e Tornar os Módulos do Kernel Persistentes
echo "[TASK 2] Configurando módulos do kernel..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "overlay" | sudo tee -a /etc/modules
echo "br_netfilter" | sudo tee -a /etc/modules
sudo update-initramfs -u

# Configurar Parâmetros do Kernel para Kubernetes
echo "[TASK 3] Configurando parâmetros sysctl..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Instalar Containerd
echo "[TASK 4] Instalando containerd..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y containerd.io

# Configurar Containerd para Kubernetes
echo "[TASK 5] Configurando containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Adicionar Repositório do Kubernetes
echo "[TASK 6] Adicionando repositório do Kubernetes..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Instalar Kubernetes (kubeadm, kubelet, kubectl)
echo "[TASK 7] Instalando Kubernetes..."
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Garantir que o kubelet sempre inicie automaticamente
echo "[TASK 8] Habilitando kubelet..."
sudo systemctl enable kubelet

# Configurar DNS Persistente
echo "[TASK 9] Configurando DNS persistente..."
echo "search svc.cluster.local cluster.local" | sudo tee -a /etc/resolv.conf
sudo chattr +i /etc/resolv.conf  # Impedir que o arquivo seja sobrescrito

echo "[FINALIZADO] Configuração concluída! Reinicie a máquina para aplicar todas as mudanças."

