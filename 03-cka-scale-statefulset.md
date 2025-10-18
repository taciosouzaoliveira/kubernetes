### **Arquivo: `03-cka-scale-statefulset.md`**

```markdown
# CKA - Questão 3: Escalar um StatefulSet

### Objetivo da Tarefa

-   **Identificar Controller:** Dado um Pod, identificar qual recurso (Deployment, StatefulSet, etc.) o está gerenciando.
-   **Escalar Recursos:** Alterar o número de réplicas de um `StatefulSet`.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:
1.  No namespace `project-c13`, existem dois Pods com o prefixo `o3db-`. [cite: 117]
2.  Escalar o recurso que gerencia esses Pods para que haja apenas **uma** réplica. [cite: 117]

---

### 1. Preparando o Ambiente no Lab

A preparação consiste em mudar para o contexto correto e inspecionar os Pods para identificar seu "dono".

```bash
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
1.1 Inspecionar os Pods
Liste os Pods no namespace project-c13. 

Bash

kubectl get pods -n project-c13
Você verá os Pods o3db-0 e o3db-1. O sufixo numérico e sequencial (-0, -1) é uma forte indicação de que eles são gerenciados por um StatefulSet. 

Para confirmar, descreva um dos Pods e procure pelo campo Controlled By.

Bash

kubectl describe pod o3db-0 -n project-c13 | grep "Controlled By"
A saída confirmará que ele é controlado pelo StatefulSet/o3db.

2. Resolvendo a Questão: Passo a Passo
A solução é usar o comando kubectl scale para alterar o número de réplicas do StatefulSet. 

Parte 1: Escalar o StatefulSet
Bash

# Sintaxe: kubectl scale <tipo> <nome> --replicas=<numero> -n <namespace>
kubectl scale statefulset o3db --replicas=1 -n project-c13
Verificação Final
Verifique se o StatefulSet foi escalado corretamente e se agora há apenas um Pod em execução.

Bash

# Verifique o status do StatefulSet
kubectl get statefulset o3db -n project-c13
A coluna READY deve mostrar 1/1. 

Bash

# Liste os Pods novamente
kubectl get pods -n project-c13
Agora, apenas o Pod o3db-0 deve estar na lista.

Conceitos Importantes para a Prova
StatefulSet: Um objeto de carga de trabalho usado para gerenciar aplicações com estado. Ele fornece garantias sobre a ordem e a unicidade de seus Pods, resultando em nomes estáveis e previsíveis (ex: web-0, web-1).

kubectl scale: Um comando imperativo rápido para alterar o número de réplicas de um Deployment, StatefulSet ou ReplicaSet.

Identificando Controllers: Saber a aparência dos nomes dos Pods ajuda a identificar rapidamente o controller:

my-sts-0, my-sts-1: StatefulSet

my-deploy-a1b2c3d4-x5y6z: ReplicaSet (gerenciado por um Deployment)

my-ds-x5y6z: DaemonSet

