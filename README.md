🚀 Home Lab para Estudos CKA Kubernetes

Bom dia, futuros kubestronautas! 🚀 Tudo bem?

Estou estudando para a certificação CKA Kubernetes e vou compartilhar como criei um cluster Kubernetes de forma simples, prática e "automatizada".

Este repositório contém o setup de um home lab que montei para estudar e praticar para a certificação CKA, utilizando ferramentas como Vagrant e Libvirt.

🚀 Meu Home Lab para Estudos do CKA Kubernetes

Para simular um cluster Kubernetes de forma eficiente, utilizei um notebook com as seguintes configurações:

Memória RAM: 16GB
Processador: Intel Core i5
Armazenamento: SSD de 256GB
Sistema Operacional: Debian 12

🏗️ Ferramentas Utilizadas no Home Lab

1️⃣ Debian 12
Escolhi o Debian por ser uma distribuição estável, confiável e compatível com as principais ferramentas de virtualização e automação.

2️⃣ Libvirt
Utilizo o Libvirt para gerenciar máquinas virtuais. No meu caso, o KVM/QEMU (parte do Libvirt) é utilizado para criar e executar as VMs de forma leve e eficiente, sendo uma alternativa ao VirtualBox com melhor desempenho e integração com Linux.

3️⃣ Vagrant
O Vagrant facilita a automação da criação e gerenciamento das máquinas virtuais. Através do Vagrantfile, defino a infraestrutura como código, onde especifico detalhes como:

Quantidade de máquinas no cluster
Configurações de CPU, memória e rede
Sistema operacional das VMs
Provisionamento automático com scripts

🛠️ Funcionamento do Home Lab
Com Vagrant + Libvirt, consigo levantar rapidamente um ambiente Kubernetes com múltiplos nós (máquinas virtuais), o que me permite testar deploys, alta disponibilidade, balanceamento de carga e outras funcionalidades exigidas no exame CKA.

O fluxo de trabalho é o seguinte:

Escrevo o Vagrantfile definindo os nós do cluster (master e workers).
Rodo o comando vagrant up para provisionar e iniciar as máquinas virtuais.
Acesso as VMs via SSH (vagrant ssh) e instalo o Kubernetes para criar o cluster.
Essa abordagem me permite recriar o ambiente de testes sempre que necessário, evitando configurações manuais demoradas.

🎯 Vantagens do Meu Setup
✅ Uso otimizado dos recursos de hardware com KVM (mais leve que o VirtualBox).
✅ Automação da criação e destruição do ambiente com Vagrant.
✅ Facilidade para simular cenários reais de um cluster Kubernetes.
Esse processo torna a criação do ambiente simples, rápida e eficiente.

📝 Scripts
Os scripts utilizados para a criação do cluster estão disponíveis no meu GitHub:
GitHub - Kubernetes Setup

🎥 Vídeos no YouTube
Publicarei em breve uma série de vídeos explicando como criar um cluster Kubernetes de forma leve e otimizada.
Meu Canal no YouTube

📢 O que você achou?
Já utilizou Vagrant e Libvirt para provisionar ambientes Kubernetes? Deixe seu comentário ou dúvida!
