# **CKA - Questão 12: Deployment com Afinidade e Topologia**

### **Objetivo da Tarefa**

- **Agendamento Avançado:** Usar regras de afinidade/anti-afinidade para controlar como os Pods de um `Deployment` são distribuídos entre os nós.
- **Topologia de Pods:** Simular o comportamento de um `DaemonSet` usando um `Deployment`, garantindo que no máximo um Pod seja agendado por nó.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`, dentro do namespace `project-tiger`:

1. Criar um `Deployment` chamado `deploy-important` com **3 réplicas**.
2. O `Deployment` e seus Pods devem ter o label `id: very-important`.
3. Os Pods devem ter dois contêineres: `container1` (imagem `nginx:1.17.6-alpine`) e `container2` (imagem `google/pause`).
4. Implementar uma regra para que **no máximo um Pod** deste `Deployment` seja agendado por nó, usando a chave de topologia `kubernetes.io/hostname`.
5. Confirmar que, como o cluster tem 2 nós de trabalho, apenas 2 dos 3 Pods fiquem em estado "Running" e o terceiro fique "Pending".

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e gerar um manifesto base para o `Deployment`.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

bash

```
# Gere um template de Deployment para usar como base# Usamos '--replicas' para já definir o número desejado
kubectl create deployment deploy-important --image=nginx:1.17.6-alpine --replicas=3 -n project-tiger --dry-run=client -o yaml > 12-deployment.yaml
```

---

### **2. Resolvendo a Questão: Passo a Passo**

A solução envolve editar o manifesto do Deployment para adicionar o segundo contêiner e a regra de `podAntiAffinity`.

### **Parte 1: Editar o Manifesto YAML**

bash

```
# Edite o arquivo YAMLnano 12-deployment.yaml
```

Faça as seguintes modificações:

- Adicione o label `id: very-important` em `metadata.labels` (Deployment) e `spec.template.metadata.labels` (Pod).
- Ajuste o `spec.selector.matchLabels` para usar `id: very-important`.
- Renomeie o primeiro contêiner para `container1`.
- Adicione o `container2` com a imagem `google/pause`.
- Adicione a seção `affinity` com a regra `podAntiAffinity`.

O arquivo final deve ficar assim:

yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-important
  namespace: project-tiger
  labels:
    id: very-important
spec:
  replicas: 3
  selector:
    matchLabels:
      id: very-important
  template:
    metadata:
      labels:
        id: very-important
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: id
                operator: In
                values:
                - very-important
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: container1
        image: nginx:1.17.6-alpine
      - name: container2
        image: google/pause
```

### **Parte 2: Criar o Deployment**

bash

```
kubectl apply -f 12-deployment.yaml
```

---

### **Verificação Final**

Verifique o status do Deployment e dos seus Pods para confirmar o resultado esperado.

bash

```
# Verifique o status do Deployment
kubectl get deployment deploy-important -n project-tiger
```

A coluna `READY` deve mostrar `2/3`, indicando que apenas 2 das 3 réplicas estão prontas.

bash

```
# Liste os Pods do Deployment com a flag -o wide
kubectl get pods -n project-tiger -l id=very-important -o wide
```

A saída deve mostrar dois Pods em estado `Running`, cada um em um nó de trabalho diferente, e um terceiro Pod em estado `Pending`.

bash

```
# Descreva o Pod pendente para ver a razão# (Substitua <pending-pod-name> pelo nome real do Pod)
kubectl describe pod <pending-pod-name> -n project-tiger
```

Nos `Events`, você verá uma mensagem `FailedScheduling` indicando que nenhum nó satisfez as regras de anti-afinidade.

---

### **Conceitos Importantes para a Prova**

- **Afinidade e Anti-afinidade:** Regras que dão ao scheduler "dicas" (preferências) ou "ordens" (requisitos) sobre onde agendar Pods.
- **Afinidade:** Atrai Pods para nós (`nodeAffinity`) ou para perto de outros Pods (`podAffinity`).
- **Anti-afinidade:** Repele Pods de nós (`nodeAntiAffinity`) ou uns dos outros (`podAntiAffinity`).
- **podAntiAffinity:** Usado para evitar que certos Pods sejam agendados no mesmo "domínio de topologia" (ex: mesmo nó, mesma zona de disponibilidade).
- **requiredDuringSchedulingIgnoredDuringExecution:** Um tipo de regra "dura". O scheduler deve satisfazer a regra para agendar o Pod. Se não for possível, o Pod fica `Pending`.
- **topologyKey:** Define o "domínio de topologia". `kubernetes.io/hostname` significa "no mesmo nó". Outros valores comuns são `topology.kubernetes.io/zone` ou `topology.kubernetes.io/region`.
- **topologySpreadConstraints:** Uma alternativa mais moderna e flexível ao `podAntiAffinity` para controlar a distribuição de Pods, mas `podAntiAffinity` ainda é um tópico importante do exame.
