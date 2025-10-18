# ☸️ Guia Completo para CKA – Certified Kubernetes Administrator

Repositório de estudos mantido por **Tácio Souza** com foco na certificação **CKA (Certified Kubernetes Administrator)** da Linux Foundation.  
Aqui estão anotações práticas, comandos essenciais, laboratórios e scripts para dominar a administração de clusters Kubernetes.

---

## 📘 Estrutura dos Tópicos

| Nº | Arquivo | Descrição |
|----|----------|------------|
| 01 | [cka-contexts.md](01-cka-contexts.md) | Gerenciamento de contextos e configurações `kubectl` |
| 02 | [cka-schedule-pod-controlplane.md](02-cka-schedule-pod-controlplane.md) | Agendamento de Pods no Control Plane |
| 03 | [cka-scale-statefulset.md](03-cka-scale-statefulset.md) | Escalonamento de StatefulSets |
| 04 | [cka-pod-readiness-probe.md](04-cka-pod-readiness-probe.md) | Readiness e Liveness Probes |
| 05 | [cka-kubectl-sorting.md](05-cka-kubectl-sorting.md) | Filtros e ordenação de recursos com `kubectl` |
| 06 | [cka-storage-pv-pvc.md](06-cka-storage-pv-pvc.md) | Persistência de dados com PVs e PVCs |
| 07 | [cka-node-pod-resource-usage.md](07-cka-node-pod-resource-usage.md) | Verificação de uso de recursos em nós e pods |
| 08 | [cka-get-controlplane-info.md](08-cka-get-controlplane-info.md) | Coleta de informações do Control Plane |
| 09 | [cka-manual-scheduling.md](09-cka-manual-scheduling.md) | Agendamento manual de Pods |
| 10 | [cka-rbac-serviceaccount-role.md](10-cka-rbac-serviceaccount-role.md) | Configuração de RBAC, Roles e ServiceAccounts |
| 11 | [cka-daemonset-on-all-nodes.md](11-cka-daemonset-on-all-nodes.md) | Implantação de DaemonSets em todos os nós |
| 12 | [cka-deployment-affinity.md](12-cka-deployment-affinity.md) | Deployments com regras de afinidade e tolerâncias |
| 13 | [cka-multi-container-pod-volume.md](13-cka-multi-container-pod-volume.md) | Pods com múltiplos containers e volumes compartilhados |
| 14 | [cka-find-cluster-information.md](14-cka-find-cluster-information.md) | Extração de informações de cluster |
| 15 | [cka-cluster-event-logging.md](15-cka-cluster-event-logging.md) | Monitoramento e registro de eventos do cluster |
| 16 | [cka-namespaces-api-resources.md](16-cka-namespaces-api-resources.md) | Gerenciamento de Namespaces e API Resources |
| 17 | [cka-find-pod-container-info.md](17-cka-find-pod-container-info.md) | Obtenção de informações de Pods e Containers |
| 18 | [cka-fix-kubelet.md](18-cka-fix-kubelet.md) | Diagnóstico e correção de falhas do kubelet |
| 19 | [cka-create-secret-and-mount.md](19-cka-create-secret-and-mount.md) | Criação e montagem de Secrets em Pods |
| 20 | [cka-update-kubernetes-version.md](20-cka-update-kubernetes-version.md) | Atualização de versão do Kubernetes |

---

## 🧠 Guia Completo

Arquivo consolidado com todos os tópicos para revisão geral:
- 📄 [guia-completo-cka.md](guia-completo-cka.md)

---

## 🛠️ Scripts e Infraestrutura

- 🧩 **[k8s-setup.sh](k8s-setup.sh)** — Script para criação e configuração do cluster Kubernetes.  
- 💻 **[Vagrantfile](Vagrantfile)** — Define a infraestrutura virtual para o home lab com Vagrant + Libvirt.

---

## 🎯 Objetivo

Este projeto tem como objetivo:
- Criar um ambiente de estudos prático para o **exame CKA**;  
- Fornecer um guia modular para revisões rápidas;  
- Compartilhar conhecimento técnico com a comunidade de Kubernetes e DevOps.

---

## 🚀 Como Utilizar

Clone este repositório e explore os módulos:

```bash
git clone https://github.com/taciosouzaoliveira/kubernetes.git
cd kubernetes
