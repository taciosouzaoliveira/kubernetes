# **CKA - Questão 2: Agendamento de Pods em Nós de Control Plane**

### **Objetivo da Tarefa**

- **Agendamento Avançado:** Agendar um Pod para ser executado exclusivamente em um nó de `control-plane`.
- **Taints e Tolerations:** Entender e aplicar `tolerations` para permitir que um Pod seja agendado em um nó com `taints`.
- **Node Selector:** Usar `nodeSelector` para forçar o agendamento de um Pod em um nó com um label específico.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:

1. Criar um Pod chamado `pod1` com a imagem `httpd:2.4.41-alpine`.
2. O contêiner deve se chamar `pod1-container`.
3. O Pod deve ser agendado **apenas** em nós de `control-plane`.
4. Não adicionar novos labels a nenhum nó do cluster.

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e inspecionar o nó de `control-plane` para descobrir seus `labels` e `taints`.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

bash

```
# Encontre o nome do nó de control-plane
kubectl get nodes
```

bash

```
# Descreva o nó de control-plane para ver seus Taints e Labels# (Substitua <controlplane-node-name> pelo nome real do nó)
kubectl describe node <controlplane-node-name>
```

Na saída, você encontrará um Taint como `node-role.kubernetes.io/control-plane:NoSchedule` e um Label como `node-role.kubernetes.io/control-plane=`.

---

### **2. Resolvendo a Questão: Passo a Passo**

A solução requer a criação de um manifesto YAML para o Pod, adicionando as seções `tolerations` e `nodeSelector`.

### **Parte 1: Gerar o Manifesto Base do Pod**

Use `kubectl run` com `--dry-run=client -o yaml` para gerar um template inicial.

bash

```
# O nome do contêiner é definido automaticamente igual ao do Pod. Vamos ajustar no YAML.
kubectl run pod1 --image=httpd:2.4.41-alpine --dry-run=client -o yaml > 02-pod.yaml
```

### **Parte 2: Editar o Manifesto YAML**

Abra o arquivo `02-pod.yaml` e adicione as seções `tolerations` e `nodeSelector`. Mude também o nome do contêiner.

bash

```
nano 02-pod.yaml
```

O arquivo final deve ficar assim:

yaml

```
apiVersion: v1
kind: Pod
metadata:
  name: pod1
  labels:
    run: pod1
spec:
  containers:
  - image: httpd:2.4.41-alpine
    name: pod1-container# Nome do contêiner ajustadotolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule"
  nodeSelector:
    node-role.kubernetes.io/control-plane: ""
```

### **Parte 3: Criar o Pod**

bash

```
kubectl apply -f 02-pod.yaml
```

---

### **Verificação Final**

Verifique se o Pod foi criado e agendado no nó correto.

bash

```
# Use '-o wide' para ver em qual nó o Pod está rodando
kubectl get pod pod1 -o wide
```

A coluna `NODE` deve mostrar o nome do seu nó de `control-plane`.

---

### **Conceitos Importantes para a Prova**

- **Taints:** São "marcas" aplicadas a um nó que repelem Pods. Por padrão, o `control-plane` tem um taint `NoSchedule` que impede o agendamento de Pods comuns.
- **Tolerations:** São "permissões" aplicadas a um Pod para que ele possa ser agendado em um nó que tenha um taint correspondente.
- **NodeSelector:** É a forma mais simples de restringir um Pod a ser agendado apenas em nós que possuem um label específico.
- **Toleration vs. NodeSelector:** Uma toleration permite que um Pod seja agendado em um nó com taint, mas não garante que ele será. Um nodeSelector força o Pod a ser agendado apenas em nós com o label correspondente. Para garantir que um Pod rode exclusivamente no `control-plane`, você precisa de ambos.
