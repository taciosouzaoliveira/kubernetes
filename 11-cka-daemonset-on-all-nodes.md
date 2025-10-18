# CKA - Questão 11: DaemonSet em Todos os Nós

### Objetivo da Tarefa

-   **Entender DaemonSets:** Criar um `DaemonSet` para garantir que uma cópia de um Pod seja executada em todos (ou alguns) nós do cluster.
-   **Configurar Recursos:** Definir requisições de recursos (`requests`) para os Pods do `DaemonSet`.
-   **Usar Tolerations:** Adicionar `tolerations` a um `DaemonSet` para permitir que seus Pods sejam agendados em nós de `control-plane`.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`, dentro do namespace `project-tiger`:
1.  Criar um `DaemonSet` chamado `ds-important`.
2.  A imagem do contêiner deve ser `httpd:2.4-alpine`.
3.  O `DaemonSet` deve ter os labels `id=ds-important` e `uuid=18426a0b-5f59-4e10-923f-c0e078e82462`.
4.  Os Pods criados devem solicitar `10m` de CPU e `10Mi` de memória.
5.  Os Pods do `DaemonSet` devem rodar em **todos** os nós, incluindo os de `control-plane`.

---

### 1. Preparando o Ambiente no Lab

A preparação consiste em mudar para o contexto correto e ter um manifesto base pronto. Como não há um comando imperativo para criar `DaemonSets`, uma boa estratégia é gerar um YAML de `Deployment` e adaptá-lo.

```bash
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
2. Resolvendo a Questão: Passo a Passo
Parte 1: Gerar um Manifesto Base e Adaptá-lo
Bash

# Gere um template de Deployment para usar como base
kubectl create deployment ds-important --image=httpd:2.4-alpine -n project-tiger --dry-run=client -o yaml > 11-daemonset.yaml
Bash

# Edite o arquivo YAML
nano 11-daemonset.yaml
Faça as seguintes modificações no arquivo:

Mude kind: Deployment para kind: DaemonSet.

Adicione os labels solicitados na seção metadata do DaemonSet.

Remova as seções replicas e strategy, que não são usadas pelo DaemonSet.

Ajuste o spec.selector.matchLabels para corresponder aos labels dos Pods.

Adicione os labels solicitados em spec.template.metadata.labels.

Adicione a seção resources.requests no contêiner.

Adicione a toleration para permitir o agendamento no control-plane.

O arquivo final deve ficar assim:

YAML

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-important
  namespace: project-tiger
  labels:
    id: ds-important
    uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
spec:
  selector:
    matchLabels:
      id: ds-important
      uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
  template:
    metadata:
      labels:
        id: ds-important
        uuid: 18426a0b-5f59-4e10-923f-c0e078e82462
    spec:
      tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      containers:
      - name: httpd
        image: httpd:2.4-alpine
        resources:
          requests:
            cpu: 10m
            memory: 10Mi
Parte 2: Criar o DaemonSet
Bash

kubectl apply -f 11-daemonset.yaml
Verificação Final
Verifique se o DaemonSet foi criado e se seus Pods estão rodando em todos os nós, incluindo o control-plane.

Bash

# Verifique o status do DaemonSet
kubectl get daemonset ds-important -n project-tiger
As colunas DESIRED, CURRENT, READY e AVAILABLE devem mostrar o número total de nós no cluster.

Bash

# Liste os Pods criados pelo DaemonSet com a flag -o wide
kubectl get pods -n project-tiger -l id=ds-important -o wide
A saída deve mostrar um Pod para cada nó do cluster (control-plane e workers).

Conceitos Importantes para a Prova
DaemonSet: Um objeto de carga de trabalho que garante que uma cópia de um Pod seja executada em um conjunto de nós. Se um nó é adicionado ao cluster, o DaemonSet automaticamente provisiona um Pod nele. Se um nó é removido, o Pod é coletado.

Casos de Uso: DaemonSets são comumente usados para agentes de monitoramento (ex: Prometheus Node Exporter), coletores de log (ex: Fluentd) e plugins de rede ou armazenamento que precisam rodar em todos os nós.

Taints e Tolerations: Assim como em Pods regulares, para que um DaemonSet agende Pods em nós de control-plane, ele precisa ter a toleration apropriada para o taint NoSchedule do control-plane.

Resource requests e limits: requests define a quantidade mínima de recursos que o contêiner precisa, usada pelo scheduler para encontrar um nó adequado. limits define a quantidade máxima que o contêiner pode consumir.

