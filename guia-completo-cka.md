# **CKA - Questão 1: Contextos e Configuração do Kubectl**

### **Objetivo da Tarefa**

- **Inspecionar Configuração:** Listar os contextos `kubectl` disponíveis.
- **Criar Scripts:** Gerar scripts para exibir o contexto atual, um usando `kubectl` e outro manipulando o arquivo de configuração diretamente.

A tarefa exige as seguintes ações:

1. Escrever os nomes de todos os contextos `kubectl` disponíveis no arquivo `/opt/course/1/contexts`.
2. Criar um script em `/opt/course/1/context_default_kubectl.sh` que exiba o nome do contexto atual usando o comando `kubectl`.
3. Criar um segundo script em `/opt/course/1/context_default_no_kubectl.sh` que exiba o nome do contexto atual **sem** usar `kubectl`.

---

### **1. Preparando o Ambiente no Lab**

A única preparação necessária é garantir que o diretório de destino para os arquivos de solução exista.

### **1.1 Criar o Diretório de Destino**

bash

```
# Crie o diretório para a soluçãosudo mkdir -p /opt/course/1
```

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Listar Todos os Contextos**

O comando `kubectl config get-contexts` pode ser usado com a opção `-o name` para listar apenas os nomes.

bash

```
# Redireciona a lista de nomes de contextos para o arquivo de destino
kubectl config get-contexts -o name > /opt/course/1/contexts
```

### **Parte 2: Criar Script com kubectl**

O subcomando `current-context` foi feito exatamente para isso.

bash

```
# Cria o script usando o comando 'echo' e o redirecionamento '>'echo "kubectl config current-context" > /opt/course/1/context_default_kubectl.sh

# Adiciona permissão de execução (boa prática)chmod +x /opt/course/1/context_default_kubectl.sh
```

### **Parte 3: Criar Script sem kubectl**

O contexto atual está definido no arquivo `~/.kube/config`. Podemos usar ferramentas de texto como `grep` e `sed` para extrair a informação.

bash

```
# Cria o script que lê o arquivo, filtra a linha e remove o prefixoecho "grep 'current-context:' ~/.kube/config | sed 's/current-context: //'" > /opt/course/1/context_default_no_kubectl.sh

# Adiciona permissão de execuçãochmod +x /opt/course/1/context_default_no_kubectl.sh
```

---

### **Verificação Final**

Execute os scripts e verifique o conteúdo dos arquivos para confirmar que a solução está correta.

bash

```
# Verifique a lista de contextoscat /opt/course/1/contexts
```

**Saída esperada:**

text

```
k8s-c1-H
k8s-c2-AC
k8s-c3-CCC
```

bash

```
# Teste o primeiro scriptsh /opt/course/1/context_default_kubectl.sh
```

bash

```
# Teste o segundo scriptsh /opt/course/1/context_default_no_kubectl.sh
```

Ambos os scripts devem retornar o nome do contexto atual.

---

### **Conceitos Importantes para a Prova**

- **`kubectl config`:** O principal comando para visualizar e gerenciar a configuração do kubectl, incluindo contextos, clusters e usuários.
- **`get-contexts`:** Subcomando para listar os contextos. A flag `o name` é útil para scripting.
- **`current-context`:** Subcomando para exibir rapidamente o nome do contexto ativo.
- **`~/.kube/config`:** O arquivo YAML padrão que armazena toda a configuração do kubectl. Saber sua estrutura básica é útil para troubleshooting.
- **Shell Tools (`grep`, `sed`):** Ferramentas essenciais para manipular texto na linha de comando, muito úteis na prova para filtrar saídas.

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

# **CKA - Questão 3: Escalar um StatefulSet**

### **Objetivo da Tarefa**

- **Identificar Controller:** Dado um Pod, identificar qual recurso (Deployment, StatefulSet, etc.) o está gerenciando.
- **Escalar Recursos:** Alterar o número de réplicas de um `StatefulSet`.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:

1. No namespace `project-c13`, existem dois Pods com o prefixo `o3db-`.
2. Escalar o recurso que gerencia esses Pods para que haja apenas **uma** réplica.

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e inspecionar os Pods para identificar seu "dono".

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

### **1.1 Inspecionar os Pods**

Liste os Pods no namespace `project-c13`.

bash

```
kubectl get pods -n project-c13
```

Você verá os Pods `o3db-0` e `o3db-1`. O sufixo numérico e sequencial (-0, -1) é uma forte indicação de que eles são gerenciados por um StatefulSet.

Para confirmar, descreva um dos Pods e procure pelo campo `Controlled By`.

bash

```
kubectl describe pod o3db-0 -n project-c13 | grep "Controlled By"
```

A saída confirmará que ele é controlado pelo `StatefulSet/o3db`.

---

### **2. Resolvendo a Questão: Passo a Passo**

A solução é usar o comando `kubectl scale` para alterar o número de réplicas do StatefulSet.

### **Parte 1: Escalar o StatefulSet**

bash

```
# Sintaxe: kubectl scale <tipo> <nome> --replicas=<numero> -n <namespace>
kubectl scale statefulset o3db --replicas=1 -n project-c13
```

---

### **Verificação Final**

Verifique se o StatefulSet foi escalado corretamente e se agora há apenas um Pod em execução.

bash

```
# Verifique o status do StatefulSet
kubectl get statefulset o3db -n project-c13
```

A coluna `READY` deve mostrar `1/1`.

bash

```
# Liste os Pods novamente
kubectl get pods -n project-c13
```

Agora, apenas o Pod `o3db-0` deve estar na lista.

---

### **Conceitos Importantes para a Prova**

- **StatefulSet:** Um objeto de carga de trabalho usado para gerenciar aplicações com estado. Ele fornece garantias sobre a ordem e a unicidade de seus Pods, resultando em nomes estáveis e previsíveis (ex: web-0, web-1).
- **kubectl scale:** Um comando imperativo rápido para alterar o número de réplicas de um Deployment, StatefulSet ou ReplicaSet.
- **Identificando Controllers:** Saber a aparência dos nomes dos Pods ajuda a identificar rapidamente o controller:
    - `my-sts-0`, `my-sts-1`: StatefulSet
    - `my-deploy-a1b2c3d4-x5y6z`: ReplicaSet (gerenciado por um Deployment)
    - `my-ds-x5y6z`: DaemonSet

# **CKA - Questão 4: Pod Pronto se o Serviço Estiver Acessível**

### **Objetivo da Tarefa**

- **Configurar Probes:** Implementar `livenessProbe` e `readinessProbe` em um Pod.
- **Entender Service Discovery:** Demonstrar como um Pod pode usar um `readinessProbe` para verificar a disponibilidade de outro serviço dentro do cluster.
- **Service e Endpoints:** Criar um Pod que corresponda ao seletor de um Serviço existente para torná-lo um `endpoint` e satisfazer a condição de prontidão do primeiro Pod.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:

1. Criar um Pod `ready-if-service-ready` (imagem `nginx:1.16.1-alpine`) com uma `livenessProbe` simples (`true`) e uma `readinessProbe` que verifica a URL `http://service-am-i-ready:80`.
2. Confirmar que este primeiro Pod não fica no estado "Ready".
3. Criar um segundo Pod, `am-i-ready` (imagem `nginx:1.16.1-alpine`), com o label `id: cross-server-ready`.
4. Confirmar que o serviço `service-am-i-ready` agora tem o segundo Pod como `endpoint` e que, como resultado, o primeiro Pod se torna "Ready".

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e inspecionar o serviço que já existe.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

bash

```
# Inspecione o serviço existente para ver seu seletor de labels
kubectl describe svc service-am-i-ready
```

Você notará que o seletor do serviço está procurando por Pods com o label `id: cross-server-ready`.

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Criar o Primeiro Pod com Probes**

Gere um manifesto base e edite-o para adicionar as probes.

bash

```
# Gere o template YAML
kubectl run ready-if-service-ready --image=nginx:1.16.1-alpine --dry-run=client -o yaml > 04-pod1.yaml
```

bash

```
# Edite o arquivo YAMLnano 04-pod1.yaml
```

Adicione as seções `livenessProbe` e `readinessProbe`:

yaml

```
apiVersion: v1
kind: Pod
metadata:
  name: ready-if-service-ready
  labels:
    run: ready-if-service-ready
spec:
  containers:
  - image: nginx:1.16.1-alpine
    name: ready-if-service-ready
    livenessProbe:
      exec:
        command:
        - "true"
    readinessProbe:
      exec:
        command:
        - "wget"
        - "-T2"
        - "-O-"
        - "http://service-am-i-ready:80"
```

bash

```
# Crie o Pod
kubectl apply -f 04-pod1.yaml
```

**Verificação Intermediária 1:**

bash

```
# Verifique o status do Pod (a coluna READY deve ser 0/1)
kubectl get pod ready-if-service-ready
```

bash

```
# Descreva o Pod para ver a razão da falha no readiness probe
kubectl describe pod ready-if-service-ready
```

### **Parte 2: Criar o Segundo Pod para Servir como Endpoint**

Crie o segundo Pod, garantindo que ele tenha o label que o serviço `service-am-i-ready` está esperando.

bash

```
# Crie o Pod 'am-i-ready' com o label correto
kubectl run am-i-ready --image=nginx:1.16.1-alpine --labels="id=cross-server-ready"
```

---

### **Verificação Final**

Após a criação do segundo Pod, o `readinessProbe` do primeiro Pod deve passar, tornando-o "Ready".

bash

```
# Verifique os endpoints do serviço. Agora ele deve listar o IP do Pod 'am-i-ready'.
kubectl get endpoints service-am-i-ready
```

bash

```
# Verifique novamente o status do primeiro Pod. Aguarde alguns segundos.# A coluna READY agora deve ser 1/1.
kubectl get pod ready-if-service-ready
```

---

### **Conceitos Importantes para a Prova**

- **livenessProbe:** Usada pelo kubelet para saber quando reiniciar um contêiner. Se a probe falhar, o contêiner é reiniciado.
- **readinessProbe:** Usada pelo kubelet para saber quando um contêiner está pronto para aceitar tráfego. Se a probe falhar, o Pod é removido dos endpoints do Serviço.
- **Probes exec:** Permitem executar um comando dentro do contêiner. Se o comando retornar código de saída 0, a probe é bem-sucedida.
- **Service e Endpoints:** Um Serviço seleciona Pods usando labels. A lista de IPs e portas dos Pods que correspondem ao seletor é mantida em um objeto Endpoints com o mesmo nome do Serviço. O kube-proxy usa essa lista para rotear o tráfego.
- **DNS do Cluster:** Serviços são automaticamente registrados no DNS interno do cluster, permitindo que outros Pods os encontrem pelo nome (ex: `service-am-i-ready`).

# **CKA - Questão 5: Ordenação com Kubectl**

### **Objetivo da Tarefa**

- **Formatação de Saída:** Usar a funcionalidade de ordenação do `kubectl` para listar recursos com base em campos específicos de seus metadados.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:

1. Criar um script em `/opt/course/5/find_pods.sh` que liste todos os Pods de todos os namespaces, ordenados por sua data de criação (`metadata.creationTimestamp`).
2. Criar um segundo script em `/opt/course/5/find_pods_uid.sh` que liste todos os Pods de todos os namespaces, ordenados por seu UID (`metadata.uid`).

---

### **1. Preparando o Ambiente no Lab**

A única preparação necessária é mudar para o contexto correto e criar o diretório de destino.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

bash

```
# Crie o diretório para a soluçãosudo mkdir -p /opt/course/5
```

---

### **2. Resolvendo a Questão: Passo a Passo**

A solução utiliza a flag `--sort-by` do `kubectl get`.

### **Parte 1: Script para Ordenar por Data de Criação**

bash

```
# Cria o script usando 'echo' e redirecionamentoecho "kubectl get pods -A --sort-by=.metadata.creationTimestamp" > /opt/course/5/find_pods.sh

# Adiciona permissão de execuçãochmod +x /opt/course/5/find_pods.sh
```

### **Parte 2: Script para Ordenar por UID**

bash

```
# Cria o segundo scriptecho "kubectl get pods -A --sort-by=.metadata.uid" > /opt/course/5/find_pods_uid.sh

# Adiciona permissão de execuçãochmod +x /opt/course/5/find_pods_uid.sh
```

---

### **Verificação Final**

Execute os scripts para confirmar que eles produzem a saída ordenada corretamente.

bash

```
# Execute o primeiro scriptsh /opt/course/5/find_pods.sh
```

A saída será uma lista de todos os Pods, com os mais antigos aparecendo primeiro.

bash

```
# Execute o segundo scriptsh /opt/course/5/find_pods_uid.sh
```

A saída será uma lista de todos os Pods, ordenados alfanumericamente por seu UID.

---

### **Conceitos Importantes para a Prova**

- **`kubectl get -A`:** A flag `A` (ou `-all-namespaces`) é um atalho para listar recursos de todos os namespaces.
- **`-sort-by`:** Uma flag poderosa do `kubectl get` que permite ordenar a saída com base em um campo do objeto, usando a sintaxe jsonpath.
- **JSONPath:** Uma linguagem de expressão para selecionar partes de um documento JSON (ou, neste caso, a representação YAML/JSON de um objeto Kubernetes).
- **O `.` no início (`.metadata...`):** Indica que o caminho começa na raiz do objeto.
- **`metadata.creationTimestamp`:** Um campo padrão em todos os objetos Kubernetes que registra quando o objeto foi criado.
- **`metadata.uid`:** Um identificador único universal (UUID) gerado pelo sistema para cada objeto criado.

# **CKA - Questão 6: Armazenamento com PersistentVolume e PersistentVolumeClaim**

### **Objetivo da Tarefa**

- **Gerenciamento de Armazenamento:** Entender o ciclo de vida do provisionamento de armazenamento estático no Kubernetes.
- **Criar PersistentVolume (PV):** Definir um volume de armazenamento disponível no cluster.
- **Criar PersistentVolumeClaim (PVC):** Solicitar um pedaço do armazenamento disponível para uso por um Pod.
- **Montar Volume em Pod:** Configurar um `Deployment` para usar o armazenamento solicitado através da PVC.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:

1. Criar um `PersistentVolume` (PV) chamado `safari-pv` com `2Gi` de capacidade, `ReadWriteOnce`, `hostPath` em `/Volumes/Data`, e **sem** `storageClassName`.
2. No namespace `project-tiger`, criar um `PersistentVolumeClaim` (PVC) chamado `safari-pvc` que solicite `2Gi` com `ReadWriteOnce` e **sem** `storageClassName`.
3. Confirmar que a PVC se ligou (`Bound`) ao PV.
4. Criar um `Deployment` chamado `safari` no namespace `project-tiger` (imagem `httpd:2.4.41-alpine`) que monte este volume em `/tmp/safari-data`.

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e ter os manifestos YAML prontos. A documentação oficial do Kubernetes é a melhor fonte para exemplos de PV e PVC.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Criar o PersistentVolume (PV)**

Crie um arquivo `06-pv.yaml`.

bash

```
nano 06-pv.yaml
```

Cole o seguinte conteúdo:

yaml

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: safari-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/Volumes/Data"
```

Aplique o manifesto:

bash

```
kubectl apply -f 06-pv.yaml
```

### **Parte 2: Criar o PersistentVolumeClaim (PVC)**

Crie um arquivo `06-pvc.yaml`.

bash

```
nano 06-pvc.yaml
```

Cole o seguinte conteúdo:

yaml

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: safari-pvc
  namespace: project-tiger
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

Aplique o manifesto:

bash

```
kubectl apply -f 06-pvc.yaml
```

**Verificação Intermediária:** Verifique se o PV e a PVC estão com o status `Bound`.

bash

```
kubectl get pv,pvc -n project-tiger
```

### **Parte 3: Criar o Deployment que Usa a PVC**

Gere um template de Deployment e edite-o para adicionar o volume.

bash

```
kubectl create deployment safari --image=httpd:2.4.41-alpine -n project-tiger --dry-run=client -o yaml > 06-deployment.yaml
```

bash

```
nano 06-deployment.yaml
```

Adicione as seções `volumes` (no nível do spec do Pod) e `volumeMounts` (no nível do container):

yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: safari
  namespace: project-tiger
  labels:
    app: safari
spec:
  replicas: 1
  selector:
    matchLabels:
      app: safari
  template:
    metadata:
      labels:
        app: safari
    spec:
      containers:
      - name: httpd
        image: httpd:2.4.41-alpine
        volumeMounts:# Adicionar esta seção- name: safari-storage
          mountPath: /tmp/safari-data
      volumes:# Adicionar esta seção- name: safari-storage
        persistentVolumeClaim:
          claimName: safari-pvc
```

Aplique o manifesto:

bash

```
kubectl apply -f 06-deployment.yaml
```

---

### **Verificação Final**

Descreva o Pod criado pelo Deployment para confirmar que o volume foi montado corretamente.

bash

```
# Encontre o nome do Pod
kubectl get pods -n project-tiger

# Descreva o Pod (substitua <pod-name> pelo nome real)
kubectl describe pod <pod-name> -n project-tiger
```

Na saída, procure pela seção `Mounts`. Ela deve mostrar que `/tmp/safari-data` foi montado a partir do volume `safari-storage`.

---

### **Conceitos Importantes para a Prova**

- **Provisionamento Estático:** O processo onde um administrador cria manualmente um PersistentVolume. O PV representa um pedaço de armazenamento real que existe no cluster.
- **PersistentVolume (PV):** Um recurso do cluster que representa uma peça de armazenamento. Ele tem um ciclo de vida independente de qualquer Pod.
- **PersistentVolumeClaim (PVC):** Uma solicitação de armazenamento feita por um usuário (ou Pod). O Kubernetes tenta satisfazer a PVC encontrando um PV compatível (em tamanho, access mode, etc.).
- **Ligação (Binding):** Quando um PV e uma PVC são compatíveis e não possuem `storageClassName` (ou possuem o mesmo), o control plane os "liga" um ao outro, marcando ambos como `Bound`.
- **volumes e volumeMounts:** A especificação de um Pod usa a seção `volumes` para declarar que volumes ele usará (referenciando uma PVC, ConfigMap, etc.) e a seção `volumeMounts` dentro de cada contêiner para especificar onde montar aquele volume no sistema de arquivos do contêiner.

# **CKA - Questão 7: Uso de Recursos de Nós e Pods**

### **Objetivo da Tarefa**

- **Monitoramento de Recursos:** Utilizar os comandos `kubectl top` para visualizar o consumo de CPU e memória de Nós e Pods.
- **Metrics Server:** Entender que `kubectl top` depende do `metrics-server` para funcionar.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:

1. Escrever o comando que mostra o uso de recursos dos **Nós** do cluster no arquivo `/opt/course/7/node.sh`.
2. Escrever o comando que mostra o uso de recursos dos **Pods e de seus contêineres individuais** no arquivo `/opt/course/7/pod.sh`.

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e garantir que o `metrics-server` está instalado e funcionando.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

bash

```
# Verifique se o metrics-server está rodando no namespace kube-system
kubectl get pods -n kube-system | grep metrics-server
```

Se o Pod estiver em estado "Running", o `kubectl top` deve funcionar.

bash

```
# Crie o diretório para a soluçãosudo mkdir -p /opt/course/7
```

---

### **2. Resolvendo a Questão: Passo a Passo**

A solução utiliza o comando `kubectl top` com diferentes subcomandos e flags.

### **Parte 1: Script para Uso de Recursos dos Nós**

bash

```
# Cria o script usando 'echo' e redirecionamentoecho "kubectl top node" > /opt/course/7/node.sh

# Adiciona permissão de execuçãochmod +x /opt/course/7/node.sh
```

### **Parte 2: Script para Uso de Recursos de Pods e Contêineres**

Para ver os contêineres individuais, usamos a flag `--containers`.

bash

```
# Cria o segundo scriptecho "kubectl top pod -A --containers=true" > /opt/course/7/pod.sh

# Adiciona permissão de execuçãochmod +x /opt/course/7/pod.sh
```

**Nota:** Adicionamos a flag `-A` (`--all-namespaces`) para garantir que todos os Pods de todos os namespaces sejam exibidos, o que é uma prática comum.

---

### **Verificação Final**

Execute os scripts para confirmar que eles produzem a saída esperada.

bash

```
# Execute o script para ver o uso de recursos dos nóssh /opt/course/7/node.sh
```

A saída será uma tabela com os nomes dos nós e seu consumo atual de CPU (em cores) e memória (em bytes).

bash

```
# Execute o script para ver o uso de recursos dos pods e contêineressh /opt/course/7/pod.sh
```

A saída será uma tabela listando cada Pod e, para cada um, os contêineres que rodam dentro dele com seus respectivos consumos de CPU e memória.

---

### **Conceitos Importantes para a Prova**

- **`kubectl top`:** O comando principal para visualizar métricas de consumo de recursos em tempo real.
- **`kubectl top node`:** Subcomando específico para exibir o uso de CPU e memória de cada nó no cluster.
- **`kubectl top pod`:** Subcomando para exibir o uso de CPU e memória dos Pods.
- **`-containers=true`:** Flag que expande a saída para mostrar o consumo de cada contêiner individualmente dentro de cada Pod.
- **Metrics Server:** Um componente crucial do cluster que coleta métricas de consumo de recursos dos kubelets em cada nó e as expõe através da API de Métricas do Kubernetes. O `kubectl top` consome dados dessa API. Sem o `metrics-server` funcionando, o comando `kubectl top` retornará um erro.

# **CKA - Questão 8: Obter Informações do Control Plane**

### **Objetivo da Tarefa**

- **Troubleshooting de Cluster:** Investigar um nó de `control-plane` para determinar como seus componentes principais e o DNS do cluster estão configurados e em execução.
- **Identificar Tipos de Componentes:** Diferenciar entre um processo do sistema (`systemd`), um `static pod` e um `pod` regular (gerenciado por um `Deployment`, etc.).

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:

1. Conectar-se via `ssh` ao nó `cluster1-controlplane1`.
2. Determinar o método de execução dos seguintes componentes: `kubelet`, `kube-apiserver`, `kube-scheduler`, `kube-controller-manager` e `etcd`.
3. Identificar o nome da aplicação de DNS do cluster e como ela é gerenciada.
4. Escrever as descobertas no arquivo `/opt/course/8/controlplane-components.txt` seguindo um formato específico.

---

### **1. Preparando o Ambiente no Lab**

A preparação é simplesmente conectar-se ao nó de `control-plane`.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

bash

```
# Conecte-se ao nóssh cluster1-controlplane1
```

---

### **2. Resolvendo a Questão: Passo a Passo**

A solução envolve usar uma combinação de comandos de sistema (`ps`, `systemctl`) e `kubectl` para investigar o nó.

### **Parte 1: Investigar o kubelet**

O kubelet é o único componente que sempre roda como um processo de sistema.

bash

```
# Procure pelo processo do kubeletps aux | grep kubelet
```

bash

```
# Verifique se ele é gerenciado pelo systemd
systemctl status kubelet
```

A saída confirmará que o kubelet é um processo (`process`).

### **Parte 2: Investigar os Outros Componentes do Control Plane**

Em um cluster configurado com kubeadm, os componentes `kube-apiserver`, `kube-scheduler`, `kube-controller-manager` e `etcd` rodam como static pods. A maneira mais rápida de confirmar isso é listar os arquivos no diretório de manifestos estáticos do kubelet.

bash

```
# O diretório padrão para manifestos estáticos é /etc/kubernetes/manifestsls /etc/kubernetes/manifests/
```

A saída listará os arquivos `kube-apiserver.yaml`, `kube-scheduler.yaml`, `kube-controller-manager.yaml`, e `etcd.yaml`, confirmando que eles são static-pods (`static-pod`).

### **Parte 3: Investigar o DNS do Cluster**

O DNS é um serviço que roda como um Pod normal dentro do cluster, geralmente no namespace `kube-system`.

bash

```
# Liste os pods no namespace kube-system para identificar o DNS
kubectl get pods -n kube-system
```

Você verá Pods com o nome `coredns-xxxxx`. Isso identifica o nome da aplicação como `coredns`. Para descobrir como ele é gerenciado, liste os Deployments no mesmo namespace.

bash

```
# Verifique se o coredns é gerenciado por um Deployment
kubectl get deployment -n kube-system | grep coredns
```

A saída confirmará que o coredns é um pod (`pod`) gerenciado por um Deployment.

### **Parte 4: Escrever o Arquivo de Resposta**

Saia da sessão ssh e crie o arquivo de resposta no seu terminal principal.

bash

```
# Crie o arquivo de respostanano /opt/course/8/controlplane-components.txt
```

**Conteúdo do arquivo:**

text

```
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
```

---

### **Conceitos Importantes para a Prova**

- **kubelet:** O agente que roda em cada nó do cluster. Ele garante que os contêineres descritos nos PodSpecs estejam rodando e saudáveis. Em clusters kubeadm, ele é instalado como um serviço systemd.
- **Static Pods:** Pods gerenciados diretamente pelo kubelet em um nó específico, sem que o api-server os observe. O kubelet monitora um diretório (geralmente `/etc/kubernetes/manifests`) e cria os Pods que correspondem aos arquivos YAML encontrados lá.
- **Componentes do Control Plane como Static Pods:** Em um cluster kubeadm, os componentes críticos (api-server, scheduler, controller-manager, etcd) são executados como static pods no nó de control-plane. Isso garante que eles possam iniciar mesmo que o api-server ainda não esteja totalmente funcional.
- **DNS do Cluster (CoreDNS):** O CoreDNS é a solução de DNS padrão para o service discovery no Kubernetes. Ele é executado como um Deployment regular dentro do cluster, geralmente no namespace `kube-system`.

# **CKA - Questão 9: Agendamento Manual de Pods**

### **Objetivo da Tarefa**

- **Gerenciar Componentes do Control Plane:** Parar e reiniciar o `kube-scheduler` para observar seu impacto no cluster.
- **Entender o Processo de Agendamento:** Simular o papel do scheduler agendando manualmente um Pod em um nó específico.
- **Manipular Manifestos de Pod:** Editar o manifesto YAML de um Pod para atribuí-lo a um nó.

A tarefa exige as seguintes ações no contexto `k8s-c2-AC`:

1. Conectar-se ao `cluster2-controlplane1` e **parar temporariamente** o `kube-scheduler`.
2. Criar um Pod `manual-schedule` (imagem `httpd:2.4-alpine`) e confirmar que ele permanece no estado `Pending`.
3. Agendar manualmente este Pod para rodar no nó `cluster2-controlplane1`.
4. Reiniciar o `kube-scheduler`.
5. Criar um segundo Pod `manual-schedule2` e confirmar que ele é agendado automaticamente pelo scheduler em um nó de trabalho (`cluster2-node1`).

---

### **1. Preparando o Ambiente no Lab**

A única preparação é conectar-se ao nó de `control-plane`.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c2-AC
```

bash

```
# Conecte-se ao nó de control-planessh cluster2-controlplane1
```

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Parar o Kube-Scheduler**

Em um cluster kubeadm, o scheduler roda como um static pod. Para pará-lo temporariamente, basta mover seu manifesto para fora do diretório `/etc/kubernetes/manifests`.

bash

```
# Mova o manifesto do scheduler para um local temporário (ex: /root)mv /etc/kubernetes/manifests/kube-scheduler.yaml /root/
```

Após alguns segundos, o kubelet detectará a ausência do arquivo e removerá o Pod do scheduler.

**Verificação:**

bash

```
kubectl get pod -n kube-system | grep scheduler
# (O comando não deve retornar nenhum Pod)
```

### **Parte 2: Criar um Pod e Confirmar o Estado Pending**

Volte para o seu terminal principal para criar o Pod.

bash

```
# Crie o Pod
kubectl run manual-schedule --image=httpd:2.4-alpine
```

bash

```
# Verifique seu status. A coluna NODE estará <none> e o STATUS será Pending.
kubectl get pod manual-schedule -o wide
```

### **Parte 3: Agendar o Pod Manualmente**

Para agendar o Pod, precisamos editar seu manifesto YAML e adicionar o campo `spec.nodeName`.

bash

```
# Obtenha o YAML do Pod e salve em um arquivo
kubectl get pod manual-schedule -o yaml > 09-pod.yaml
```

bash

```
# Edite o arquivonano 09-pod.yaml
```

Adicione a linha `nodeName: cluster2-controlplane1` dentro da seção `spec`:

yaml

```
apiVersion: v1
kind: Pod
# ... (metadados)spec:
  nodeName: cluster2-controlplane1# Adicionar esta linhacontainers:
# ... (resto da especificação)
```

Como não podemos editar um Pod em execução dessa forma, precisamos deletá-lo e recriá-lo a partir do arquivo modificado.

bash

```
# --force --grace-period=0 deleta o Pod imediatamente
kubectl delete pod manual-schedule --force --grace-period=0
```

bash

```
# Crie o Pod a partir do manifesto modificado
kubectl apply -f 09-pod.yaml
```

**Verificação:**

bash

```
# O Pod agora deve estar Running no nó de control-plane
kubectl get pod manual-schedule -o wide
```

**Nota:** O Pod é agendado no control-plane mesmo sem tolerations porque, ao definir o `nodeName` manualmente, nós contornamos a lógica de agendamento do scheduler, que é quem avalia os taints.

### **Parte 4: Reiniciar o Scheduler e Testar**

Volte para a sessão SSH no control-plane e mova o manifesto do scheduler de volta para seu lugar.

bash

```
# Mova o arquivo de volta para o diretório de manifestosmv /root/kube-scheduler.yaml /etc/kubernetes/manifests/
```

O kubelet detectará o arquivo e iniciará o Pod do scheduler novamente.

**Verificação Final:** No seu terminal principal, crie o segundo Pod e verifique onde ele é agendado.

bash

```
# Crie o segundo Pod
kubectl run manual-schedule2 --image=httpd:2.4-alpine
```

bash

```
# Aguarde alguns segundos e verifique onde os Pods estão rodando
kubectl get pods -o wide | grep manual-schedule
```

A saída deve mostrar `manual-schedule` rodando no `cluster2-controlplane1` e `manual-schedule2` rodando em um nó de trabalho, como `cluster2-node1`, confirmando que o scheduler está funcionando.

---

### **Conceitos Importantes para a Prova**

- **Parando Static Pods:** A maneira de parar/iniciar um static pod é mover seu manifesto para fora ou para dentro do diretório `/etc/kubernetes/manifests`.
- **O Papel do Scheduler:** A principal função do `kube-scheduler` é observar Pods que não têm um nó (`spec.nodeName` está vazio) e, com base em filtros e prioridades (recursos, taints, afinidade), escolher o melhor nó e atualizar o `spec.nodeName` do Pod.
- **Agendamento Manual:** Ao definir o campo `spec.nodeName` diretamente no manifesto de um Pod, você está efetivamente fazendo o trabalho do scheduler e forçando o kubelet daquele nó específico a executar o Pod.
- **Agendamento Manual e Taints:** O agendamento manual ignora os taints do nó, pois o scheduler (que é quem os verifica) não está envolvido no processo.

# **CKA - Questão 10: RBAC com ServiceAccount, Role e RoleBinding**

### **Objetivo da Tarefa**

- **RBAC (Role-Based Access Control):** Entender e criar os principais recursos do RBAC para conceder permissões a uma conta de serviço dentro de um namespace específico.
- **Criar ServiceAccount:** Criar uma identidade para um processo que roda dentro de um Pod.
- **Criar Role e RoleBinding:** Definir um conjunto de permissões (`Role`) e associá-lo a um `ServiceAccount` (`RoleBinding`).

A tarefa exige as seguintes ações no contexto `k8s-c1-H`, dentro do namespace `project-hamster`:

1. Criar um novo `ServiceAccount` chamado `processor`.
2. Criar uma `Role` chamada `processor` que conceda permissão para **apenas criar** (`create`) os recursos `Secrets` e `ConfigMaps`.
3. Criar uma `RoleBinding` chamada `processor` que associe a `Role` criada ao `ServiceAccount` criado.

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e garantir que o namespace existe.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

bash

```
# Verifique se o namespace existe (o simulado assume que sim)
kubectl get ns project-hamster
```

---

### **2. Resolvendo a Questão: Passo a Passo**

A solução envolve criar os três recursos em sequência usando comandos imperativos `kubectl create`.

### **Parte 1: Criar o ServiceAccount**

bash

```
# Sintaxe: kubectl create serviceaccount <nome> -n <namespace>
kubectl create serviceaccount processor -n project-hamster
```

### **Parte 2: Criar a Role**

O comando `kubectl create role` permite definir as permissões de forma imperativa.

bash

```
# Sintaxe: kubectl create role <nome> --verb=<verbo> --resource=<recurso> -n <namespace># Podemos adicionar múltiplos verbos ou recursos
kubectl create role processor --verb=create --resource=secrets --resource=configmaps -n project-hamster
```

### **Parte 3: Criar a RoleBinding**

O RoleBinding conecta o "sujeito" (ServiceAccount) ao conjunto de permissões (Role).

bash

```
# Sintaxe: kubectl create rolebinding <nome> --role=<nome_da_role> --serviceaccount=<namespace>:<nome_do_sa> -n <namespace>
kubectl create rolebinding processor --role=processor --serviceaccount=project-hamster:processor -n project-hamster
```

---

### **Verificação Final**

Use o comando `kubectl auth can-i` para verificar se as permissões foram aplicadas corretamente. Este comando simula uma ação como se fosse o ServiceAccount.

bash

```
# Teste se o SA pode criar um secret (deve retornar "yes")
kubectl auth can-i create secret --as=system:serviceaccount:project-hamster:processor -n project-hamster

# Teste se o SA pode criar um configmap (deve retornar "yes")
kubectl auth can-i create configmap --as=system:serviceaccount:project-hamster:processor -n project-hamster

# Teste se o SA pode criar um pod (deve retornar "no")
kubectl auth can-i create pod --as=system:serviceaccount:project-hamster:processor -n project-hamster

# Teste se o SA pode deletar um secret (deve retornar "no")
kubectl auth can-i delete secret --as=system:serviceaccount:project-hamster:processor -n project-hamster
```

---

### **Conceitos Importantes para a Prova**

- **RBAC:** O mecanismo padrão do Kubernetes para controlar o acesso à API. Baseia-se em quatro objetos principais.
- **ServiceAccount:** Fornece uma identidade para processos que rodam dentro de um Pod.
- **Role:** Um conjunto de permissões (regras) que se aplica a um único namespace. Cada regra define verbos (`get`, `list`, `create`, `delete`) que podem ser executados em um conjunto de recursos (`pods`, `secrets`).
- **ClusterRole:** Semelhante a uma Role, mas suas permissões são válidas para o cluster inteiro.
- **RoleBinding:** Conecta um Role a um "sujeito" (User, Group, ou ServiceAccount), concedendo as permissões da Role àquele sujeito dentro do namespace da RoleBinding.
- **ClusterRoleBinding:** Conecta um ClusterRole a um sujeito, concedendo as permissões em todo o cluster.
- **`kubectl auth can-i`:** Uma ferramenta de depuração extremamente útil para verificar se um determinado usuário ou ServiceAccount tem permissão para realizar uma ação.
- **`-as`:** Flag para personificar outro usuário ou conta de serviço.
- **Sintaxe do SA:** `system:serviceaccount:<namespace>:<nome_do_sa>`.

# **CKA - Questão 11: DaemonSet em Todos os Nós**

### **Objetivo da Tarefa**

- **Entender DaemonSets:** Criar um `DaemonSet` para garantir que uma cópia de um Pod seja executada em todos (ou alguns) nós do cluster.
- **Configurar Recursos:** Definir requisições de recursos (`requests`) para os Pods do `DaemonSet`.
- **Usar Tolerations:** Adicionar `tolerations` a um `DaemonSet` para permitir que seus Pods sejam agendados em nós de `control-plane`.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`, dentro do namespace `project-tiger`:

1. Criar um `DaemonSet` chamado `ds-important`.
2. A imagem do contêiner deve ser `httpd:2.4-alpine`.
3. O `DaemonSet` deve ter os labels `id=ds-important` e `uuid=18426a0b-5f59-4e10-923f-c0e078e82462`.
4. Os Pods criados devem solicitar `10m` de CPU e `10Mi` de memória.
5. Os Pods do `DaemonSet` devem rodar em **todos** os nós, incluindo os de `control-plane`.

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e ter um manifesto base pronto. Como não há um comando imperativo para criar `DaemonSets`, uma boa estratégia é gerar um YAML de `Deployment` e adaptá-lo.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Gerar um Manifesto Base e Adaptá-lo**

bash

```
# Gere um template de Deployment para usar como base
kubectl create deployment ds-important --image=httpd:2.4-alpine -n project-tiger --dry-run=client -o yaml > 11-daemonset.yaml
```

bash

```
# Edite o arquivo YAMLnano 11-daemonset.yaml
```

Faça as seguintes modificações no arquivo:

- Mude `kind: Deployment` para `kind: DaemonSet`.
- Adicione os labels solicitados na seção `metadata` do DaemonSet.
- Remova as seções `replicas` e `strategy`, que não são usadas pelo DaemonSet.
- Ajuste o `spec.selector.matchLabels` para corresponder aos labels dos Pods.
- Adicione os labels solicitados em `spec.template.metadata.labels`.
- Adicione a seção `resources.requests` no contêiner.
- Adicione a `toleration` para permitir o agendamento no control-plane.

O arquivo final deve ficar assim:

yaml

```
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
```

### **Parte 2: Criar o DaemonSet**

bash

```
kubectl apply -f 11-daemonset.yaml
```

---

### **Verificação Final**

Verifique se o DaemonSet foi criado e se seus Pods estão rodando em todos os nós, incluindo o control-plane.

bash

```
# Verifique o status do DaemonSet
kubectl get daemonset ds-important -n project-tiger
```

As colunas `DESIRED`, `CURRENT`, `READY` e `AVAILABLE` devem mostrar o número total de nós no cluster.

bash

```
# Liste os Pods criados pelo DaemonSet com a flag -o wide
kubectl get pods -n project-tiger -l id=ds-important -o wide
```

A saída deve mostrar um Pod para cada nó do cluster (control-plane e workers).

---

### **Conceitos Importantes para a Prova**

- **DaemonSet:** Um objeto de carga de trabalho que garante que uma cópia de um Pod seja executada em um conjunto de nós. Se um nó é adicionado ao cluster, o DaemonSet automaticamente provisiona um Pod nele. Se um nó é removido, o Pod é coletado.
- **Casos de Uso:** DaemonSets são comumente usados para agentes de monitoramento (ex: Prometheus Node Exporter), coletores de log (ex: Fluentd) e plugins de rede ou armazenamento que precisam rodar em todos os nós.
- **Taints e Tolerations:** Assim como em Pods regulares, para que um DaemonSet agende Pods em nós de control-plane, ele precisa ter a toleration apropriada para o taint `NoSchedule` do control-plane.
- **Resource requests e limits:** `requests` define a quantidade mínima de recursos que o contêiner precisa, usada pelo scheduler para encontrar um nó adequado. `limits` define a quantidade máxima que o contêiner pode consumir.

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

---

# **CKA - Questão 13: Pod com Múltiplos Contêineres e Volume Compartilhado**

### **Objetivo da Tarefa**

- **Pods com Múltiplos Contêineres:** Criar um único Pod que executa vários contêineres.
- **Volumes `emptyDir`:** Usar um volume `emptyDir` para compartilhar dados entre contêineres dentro do mesmo Pod.
- **Injeção de Metadados (Downward API):** Expor informações do próprio Pod (como o nome do nó) como uma variável de ambiente para um contêiner.

A tarefa exige a criação de um Pod `multi-container-playground` com as seguintes características:

1. Deve ter três contêineres: `c1`, `c2`, e `c3`.
2. Um volume deve ser compartilhado entre os três contêineres, mas não deve ser persistente.
3. **Contêiner `c1`**: Imagem `nginx:1.17.6-alpine`. Deve ter uma variável de ambiente `MY_NODE_NAME` com o nome do nó onde o Pod está rodando.
4. **Contêiner `c2`**: Imagem `busybox:1.31.1`. Deve escrever a data a cada segundo no arquivo `date.log` dentro do volume compartilhado.
5. **Contêiner `c3`**: Imagem `busybox:1.31.1`. Deve ler continuamente o arquivo `date.log` e imprimir seu conteúdo na saída padrão (logs).

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e gerar um manifesto base para o Pod.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

bash

```
# Gere um template de Pod para usar como base
kubectl run multi-container-playground --image=nginx:1.17.6-alpine --dry-run=client -o yaml > 13-pod.yaml
```

---

### **2. Resolvendo a Questão: Passo a Passo**

A solução envolve editar o manifesto YAML para adicionar os outros contêineres, o volume `emptyDir` e as respectivas montagens e configurações.

### **Parte 1: Editar o Manifesto YAML**

bash

```
# Edite o arquivo YAMLnano 13-pod.yaml
```

Modifique o arquivo para refletir todos os requisitos.

yaml

```
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-playground
  labels:
    run: multi-container-playground
spec:
# 1. Definir o volume compartilhadovolumes:
  - name: shared-data
    emptyDir: {}
  containers:
# 2. Configurar o contêiner c1- name: c1
    image: nginx:1.17.6-alpine
    env:
    - name: MY_NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    volumeMounts:
    - name: shared-data
      mountPath: /data
# 3. Configurar o contêiner c2- name: c2
    image: busybox:1.31.1
    command: ["/bin/sh", "-c"]
    args: ["while true; do date >> /data/date.log; sleep 1; done"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
# 4. Configurar o contêiner c3- name: c3
    image: busybox:1.31.1
    command: ["/bin/sh", "-c"]
    args: ["tail -f /data/date.log"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
```

### **Parte 2: Criar o Pod**

bash

```
kubectl apply -f 13-pod.yaml
```

---

### **Verificação Final**

Verifique se cada parte da configuração está funcionando como esperado.

bash

```
# Espere o Pod ficar 'Running' (READY deve ser 3/3)
kubectl get pod multi-container-playground
```

bash

```
# Verifique a variável de ambiente no contêiner c1
kubectl exec multi-container-playground -c c1 -- env | grep MY_NODE_NAME
```

bash

```
# Verifique os logs do contêiner c3 para ver a saída do c2# -c c3: especifica o contêiner, -f: segue os logs em tempo real
kubectl logs multi-container-playground -c c3 -f
```

A saída deve mostrar uma nova linha com a data sendo adicionada a cada segundo.

---

### **Conceitos Importantes para a Prova**

- **Padrão Sidecar:** Um Pod com múltiplos contêineres é frequentemente usado para implementar o padrão "sidecar", onde um contêiner principal (ex: nginx) é auxiliado por outros contêineres que realizam tarefas secundárias (ex: coletar logs, atualizar configurações).
- **emptyDir Volume:** Um tipo de volume que é criado quando um Pod é atribuído a um nó e existe enquanto o Pod estiver rodando naquele nó. Seu conteúdo é perdido quando o Pod é removido. É a maneira mais simples de compartilhar arquivos entre contêineres no mesmo Pod.
- **Downward API:** Um mecanismo que permite expor metadados do próprio Pod (como labels, annotations, namespace, nodeName) para os contêineres que rodam dentro dele, seja como variáveis de ambiente ou como arquivos.
- **valueFrom.fieldRef.fieldPath:** Usado para injetar campos da especificação do Pod como variáveis de ambiente.
- **command e args:** Permitem sobrescrever o `ENTRYPOINT` e `CMD` da imagem do contêiner, respectivamente. É essencial para executar comandos customizados.
- **kubectl logs -c <container-name>:** Quando um Pod tem múltiplos contêineres, a flag `c` é obrigatória para especificar de qual contêiner você quer ver os logs.

---

# **CKA - Questão 14: Encontrar Informações do Cluster**

### **Objetivo da Tarefa**

- **Inspeção de Cluster:** Utilizar uma combinação de comandos `kubectl` e de sistema (dentro do nó de `control-plane`) para coletar informações fundamentais sobre a configuração do cluster.

A tarefa exige encontrar as seguintes informações sobre o cluster `k8s-c1-H`:

1. Quantos nós de `control-plane` estão disponíveis?
2. Quantos nós de trabalho (`worker`) estão disponíveis?
3. Qual é o `Service CIDR` do cluster?
4. Qual plugin de rede (CNI) está configurado e onde está seu arquivo de configuração?
5. Qual será o sufixo dos `static pods` que rodam no nó `cluster1-node1`?
6. Escrever as respostas no arquivo `/opt/course/14/cluster-info`.

---

### **1. Resolvendo a Questão: Passo a Passo**

A solução envolve uma série de comandos de investigação.

### **Parte 1 e 2: Contar Nós de Control Plane e Workers**

Use `kubectl get nodes` para listar todos os nós e inspecione a coluna `ROLES`.

bash

```
kubectl get nodes
```

A saída mostrará um nó com o role `control-plane` e dois nós com role `<none>` (workers).

**Resposta 1:** 1

**Resposta 2:** 2

### **Parte 3: Encontrar o Service CIDR**

O Service CIDR é uma configuração do kube-apiserver. Em um cluster kubeadm, podemos encontrá-lo no manifesto do static pod do api-server.

bash

```
# Conecte-se ao nó de control-planessh cluster1-controlplane1
```

bash

```
# Inspecione o manifesto do api-server e procure pela flag '--service-cluster-ip-range'grep 'service-cluster-ip-range' /etc/kubernetes/manifests/kube-apiserver.yaml
```

A saída mostrará o CIDR.

**Resposta 3:** 10.96.0.0/12

### **Parte 4: Encontrar o Plugin CNI**

A configuração da CNI (Container Network Interface) geralmente fica no diretório `/etc/cni/net.d/` em cada nó.

bash

```
# Ainda no control-plane, liste os arquivos no diretório da CNIls /etc/cni/net.d/
```

A saída mostrará um arquivo como `10-weave.conflist`, indicando que o plugin é o Weave. O arquivo de configuração é o próprio caminho.

**Resposta 4:** Weave, /etc/cni/net.d/10-weave.conflist

### **Parte 5: Encontrar o Sufixo dos Static Pods**

O kubelet cria static pods no api-server e adiciona um sufixo ao nome do Pod que é o nome do nó onde ele está rodando.

bash

```
# Você pode observar isso nos pods do control-plane
kubectl get pods -n kube-system
# Você verá pods como 'etcd-cluster1-controlplane1'
```

Portanto, o sufixo para um static pod rodando em `cluster1-node1` será o próprio nome do nó.

**Resposta 5:** -cluster1-node1

---

### **2. Escrever o Arquivo de Resposta**

Saia da sessão ssh e crie o arquivo de resposta no seu terminal principal.

bash

```
# Crie o arquivo de respostanano /opt/course/14/cluster-info
```

**Conteúdo do arquivo:**

text

```
1: 1
2: 2
3: 10.96.0.0/12
4: Weave, /etc/cni/net.d/10-weave.conflist
5: -cluster1-node1
```

---

### **Conceitos Importantes para a Prova**

- **`kubectl get nodes`:** Comando fundamental para listar os nós e ver seus status e roles.
- **Service CIDR (`-service-cluster-ip-range`):** O bloco de IPs virtuais que o Kubernetes usará para alocar para os Serviços (ClusterIPs). É uma configuração chave do kube-apiserver e do kube-controller-manager.
- **CNI (Container Network Interface):** Uma especificação que define como a rede de contêineres é configurada. Plugins populares incluem Weave Net, Calico, Flannel, etc. Suas configurações são lidas pelo kubelet a partir de `/etc/cni/net.d/`.
- **Sufixo de Static Pods:** Para que o api-server saiba em qual nó um static pod está rodando (já que ele não foi agendado pelo scheduler), o kubelet adiciona `<nome-do-no>` ao nome do Pod que ele cria no api-server.

---

# **CKA - Questão 15: Log de Eventos do Cluster**

### **Objetivo da Tarefa**

- **Monitorar Eventos:** Utilizar `kubectl` para visualizar os eventos do cluster, que são registros de mudanças de estado e problemas.
- **Troubleshooting:** Observar e comparar os eventos gerados por diferentes tipos de falha (deleção de Pod vs. finalização de contêiner) para entender o comportamento de auto-recuperação do Kubernetes.

A tarefa exige as seguintes ações no contexto `k8s-c2-AC`:

1. Criar um script `/opt/course/15/cluster_events.sh` que mostre os eventos mais recentes de todo o cluster, ordenados por tempo.
2. Deletar o Pod `kube-proxy` que está rodando no nó `cluster2-node1` e salvar os eventos resultantes em `/opt/course/15/pod_kill.log`.
3. Finalizar o contêiner `containerd` do Pod `kube-proxy` no nó `cluster2-node1` e salvar os eventos resultantes em `/opt/course/15/container_kill.log`.

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e criar o diretório de destino.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c2-AC
```

bash

```
# Crie o diretório para a soluçãosudo mkdir -p /opt/course/15
```

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Criar o Script de Eventos**

bash

```
# Cria o script que obtém todos os eventos (-A) e os ordena por data de criaçãoecho "kubectl get events -A --sort-by=.metadata.creationTimestamp" > /opt/course/15/cluster_events.sh

# Adiciona permissão de execuçãochmod +x /opt/course/15/cluster_events.sh
```

### **Parte 2: Deletar o Pod kube-proxy**

Primeiro, encontre o nome exato do Pod kube-proxy no nó `cluster2-node1`.

bash

```
# Liste os pods kube-proxy com '-o wide' para ver os nós
kubectl get pods -n kube-system -o wide | grep kube-proxy
# Anote o nome do pod que está em cluster2-node1 (ex: kube-proxy-264cg)
```

Agora, delete o Pod e capture os eventos.

bash

```
# Delete o Pod (substitua pelo nome correto)
kubectl delete pod <kube-proxy-pod-name> -n kube-system
```

bash

```
# Espere alguns segundos e execute o script para capturar os eventossh /opt/course/15/cluster_events.sh > /opt/course/15/pod_kill.log
```

**Análise:** Os eventos mostrarão que o DaemonSet detectou a ausência do Pod e criou um novo (`SuccessfulCreate`), que foi agendado (`Scheduled`), teve sua imagem baixada (`Pulled`) e iniciado (`Started`).

### **Parte 3: Finalizar o Contêiner kube-proxy**

Conecte-se ao nó e use `crictl` para encontrar e finalizar o contêiner.

bash

```
# Conecte-se ao nóssh cluster2-node1
```

bash

```
# Encontre o ID do contêiner do kube-proxy
crictl ps | grep kube-proxy
# Anote o CONTAINER ID
```

bash

```
# Pare o contêiner (substitua pelo ID correto)
crictl stop <container_id>
```

bash

```
# Saia da sessão sshexit
```

Agora, capture os eventos resultantes.

bash

```
# Espere alguns segundos e execute o script novamentesh /opt/course/15/cluster_events.sh > /opt/course/15/container_kill.log
```

**Análise:** Os eventos serão diferentes. Como o Pod ainda existe, o kubelet detecta que o contêiner parou e simplesmente o reinicia, gerando eventos como `Created` e `Started` para o contêiner, mas não eventos relacionados ao DaemonSet ou ao agendamento.

---

### **Conceitos Importantes para a Prova**

- **`kubectl get events`:** O comando principal para visualizar o fluxo de eventos do cluster. Eventos são recursos que fornecem insights sobre o que está acontecendo dentro do cluster, como decisões do scheduler, falhas de probes, etc.
- **`-sort-by`:** Usado para ordenar os eventos cronologicamente, facilitando a análise dos acontecimentos mais recentes.
- **Controladores (ex: DaemonSet):** Quando um objeto gerenciado por um controlador (como um Pod de um DaemonSet) é deletado, o controlador age para restaurar o estado desejado, neste caso, criando um novo Pod. Isso gera uma série de eventos.
- **Kubelet e Ciclo de Vida do Contêiner:** Quando um contêiner dentro de um Pod falha ou é finalizado, é responsabilidade do kubelet no nó reiniciar o contêiner, de acordo com a `restartPolicy` do Pod. Isso é um evento de nível de Pod/nó, não de nível de controlador.
- **`crictl`:** A ferramenta de linha de comando para inspecionar e depurar o container runtime (como containerd). É útil para interagir diretamente com os contêineres em um nó, contornando o kubelet.

# **CKA - Questão 16: Namespaces e Recursos da API**

### **Objetivo da Tarefa**

- **Explorar a API:** Listar os tipos de recursos que existem no Kubernetes e diferenciar entre os que são contidos em um `namespace` e os que são de escopo de cluster.
- **Scripting e Filtros:** Usar `kubectl` em combinação com ferramentas de shell (`wc`) para contar recursos em diferentes namespaces.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:

1. Escrever os nomes de todos os recursos Kubernetes que são **namespaced** (contidos em um namespace) no arquivo `/opt/course/16/resources.txt`.
2. Encontrar o namespace do tipo "project" que tem o maior número de `Roles` e escrever seu nome e a contagem no arquivo `/opt/course/16/crowded-namespace.txt`.

---

### **1. Preparando o Ambiente no Lab**

A preparação envolve mudar para o contexto correto e criar o diretório de destino.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

bash

```
# Crie o diretório para a soluçãosudo mkdir -p /opt/course/16
```

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Listar Recursos Namespaced**

O comando `kubectl api-resources` é a ferramenta perfeita para isso.

bash

```
# A flag '--namespaced=true' filtra apenas os recursos que vivem dentro de um namespace.# '-o name' formata a saída para mostrar apenas os nomes dos recursos, um por linha.
kubectl api-resources --namespaced=true -o name > /opt/course/16/resources.txt
```

### **Parte 2: Encontrar o Namespace com Mais Roles**

Precisamos listar as Roles em cada namespace "project" e contar as linhas. Um pequeno loop de shell pode automatizar isso.

bash

```
# Primeiro, liste todos os namespaces para ver quais são do tipo "project"
kubectl get ns
```

bash

```
# Agora, para cada namespace, conte as roles.# '--no-headers' remove a linha de cabeçalho, para que 'wc -l' conte apenas os recursos.
kubectl get role -n project-c13 --no-headers | wc -l
kubectl get role -n project-c14 --no-headers | wc -l
kubectl get role -n project-hamster --no-headers | wc -l
# ... e assim por diante para todos os namespaces relevantes.
```

Após executar os comandos, você identificará que `project-c14` é o que tem mais Roles.

bash

```
# Crie o arquivo de resposta com o resultado encontradoecho "project-c14 with 300 resources" > /opt/course/16/crowded-namespace.txt
```

---

### **Verificação Final**

Verifique o conteúdo dos arquivos criados.

bash

```
# Verifique a lista de recursos namespacedcat /opt/course/16/resources.txt
```

bash

```
# Verifique o resultado da contagem de rolescat /opt/course/16/crowded-namespace.txt
```

---

### **Conceitos Importantes para a Prova**

- **Recursos Namespaced vs. Cluster-Scoped:**
    - **Namespaced:** A maioria dos recursos, como Pods, Deployments, Services, Secrets, Roles, RoleBindings, vivem dentro de um namespace, que funciona como um escopo virtual.
    - **Cluster-Scoped:** Alguns recursos são globais para o cluster e não pertencem a nenhum namespace, como Nodes, PersistentVolumes, ClusterRoles, ClusterRoleBindings.
- **`kubectl api-resources`:** Um comando de exploração muito útil que lista todos os tipos de recursos que a API do cluster suporta, incluindo seus nomes curtos (`po`, `svc`), se são namespaced, e a qual grupo de API pertencem.
- **`-no-headers`:** Uma flag útil para `kubectl get` que remove a linha de cabeçalho da saída, facilitando o processamento da saída por outras ferramentas como `wc -l`.
- **`wc -l`:** Um comando de shell padrão que conta o número de linhas (`l`) em sua entrada, perfeito para contar recursos listados pelo `kubectl`.

# **CKA - Questão 17: Encontrar Contêiner de um Pod e Verificar Informações**

### **Objetivo da Tarefa**

- **Interação Nó-Contêiner:** Entender a relação entre um `Pod` do Kubernetes e o contêiner real que roda no nó.
- **Uso de `crictl`:** Utilizar a ferramenta de linha de comando `crictl` para interagir diretamente com o `container runtime` do nó (ex: `containerd`).

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:

1. No namespace `project-tiger`, criar um Pod `tigers-reunite` (imagem `httpd:2.4.41-alpine`) com labels `pod=container` e `container=pod`.
2. Descobrir em qual nó o Pod foi agendado e conectar-se a ele via `ssh`.
3. No nó, usar `crictl` para encontrar o contêiner correspondente ao Pod.
4. Escrever o ID do contêiner e o `info.runtimeType` em `/opt/course/17/pod-container.txt`.
5. Escrever os logs do contêiner em `/opt/course/17/pod-container.log`.

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e criar o diretório de destino.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
```

bash

```
# Crie o diretório para a soluçãosudo mkdir -p /opt/course/17
```

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Criar o Pod e Encontrar seu Nó**

bash

```
# Crie o Pod com os labels especificados
kubectl run tigers-reunite --image=httpd:2.4.41-alpine --labels="pod=container,container=pod" -n project-tiger
```

bash

```
# Espere o Pod ficar 'Running' e use '-o wide' para ver em qual nó ele está
kubectl get pod tigers-reunite -n project-tiger -o wide
# Anote o nome do nó (ex: cluster1-node2)
```

### **Parte 2: Encontrar o Contêiner e Extrair Informações**

Conecte-se ao nó onde o Pod está rodando e use `crictl`.

bash

```
# Conecte-se ao nó (substitua pelo nome do nó correto)ssh <node-name>
```

bash

```
# Use 'crictl ps' para listar os contêineres e 'grep' para encontrar o que pertence ao nosso Pod
crictl ps | grep tigers-reunite
# Anote o CONTAINER ID (ex: b01edbe6f89ed)
```

bash

```
# Use 'crictl inspect' para obter os detalhes do contêiner e filtre pelo runtimeType
crictl inspect <container-id> | grep runtimeType
# Saída esperada: "runtimeType": "io.containerd.runc.v2"
```

### **Parte 3: Escrever os Arquivos de Resposta**

Saia da sessão ssh e crie os arquivos de resposta no seu terminal principal.

bash

```
# Crie o primeiro arquivo com o ID e o runtimeTypeecho "b01edbe6f89ed io.containerd.runc.v2" > /opt/course/17/pod-container.txt
```

Volte ao nó para coletar os logs.

bash

```
# Conecte-se novamente ao nóssh <node-name>
```

bash

```
# Use 'crictl logs' e redirecione a saída para o arquivo de destino no seu terminal principal# Isso pode ser feito em um único comando, mas para o exame, copiar e colar pode ser mais simples.
crictl logs <container-id>
# Copie a saída e cole no arquivo local:# nano /opt/course/17/pod-container.log
```

Uma maneira mais avançada de fazer isso em um passo:

bash

```
ssh <node-name> "crictl logs <container-id>" &> /opt/course/17/pod-container.log
```

---

### **Verificação Final**

Verifique o conteúdo dos arquivos criados para garantir que eles contêm as informações corretas.

bash

```
cat /opt/course/17/pod-container.txt
```

bash

```
cat /opt/course/17/pod-container.log
```

---

### **Conceitos Importantes para a Prova**

- **`crictl`:** A ferramenta de linha de comando padrão para depurar e inspecionar o Container Runtime Interface (CRI). Ela permite interagir diretamente com o runtime (como containerd ou CRI-O) em um nó, de forma independente do kubelet.
- **Relação Pod-Contêiner:** Um Pod do Kubernetes é uma abstração. A entidade real que executa o código é o contêiner (containerd, docker, etc.) no nó. Saber como fazer essa ligação é crucial para troubleshooting de baixo nível.
- **Comandos crictl:**
    - `crictl ps`: Lista os contêineres em execução no nó (semelhante a `docker ps`).
    - `crictl inspect`: Fornece um JSON detalhado sobre um contêiner (semelhante a `docker inspect`).
    - `crictl logs`: Exibe os logs de um contêiner (semelhante a `docker logs`).
- **Container Runtime:** O software responsável por executar os contêineres. O Kubernetes interage com ele através do CRI. `containerd` é o runtime padrão na maioria das instalações modernas.

---

# **CKA - Questão 18: Consertar o Kubelet**

### **Objetivo da Tarefa**

- **Troubleshooting de Nó:** Diagnosticar e resolver um problema que impede um nó de se juntar ao cluster, especificamente um `kubelet` que não inicia.
- **Análise de Serviços `systemd`:** Usar `systemctl` e `journalctl` para inspecionar o status e os logs de um serviço de sistema.
- **Corrigir Configurações:** Identificar e corrigir um erro de configuração em um arquivo de serviço do `systemd`.

A tarefa exige as seguintes ações no contexto `k8s-c3-CCC`:

1. O nó `cluster3-node1` está em estado `NotReady`.
2. Diagnosticar o motivo pelo qual o `kubelet` não está rodando corretamente no nó.
3. Corrigir o problema para que o `kubelet` inicie e o nó mude para o estado `Ready`.
4. Escrever a causa do problema no arquivo `/opt/course/18/reason.txt`.

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e observar o estado inicial dos nós.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c3-CCC
```

bash

```
# Verifique o status dos nós. 'cluster3-node1' deve estar 'NotReady'.
kubectl get nodes
```

---

### **2. Resolvendo a Questão: Passo a Passo**

O fluxo de troubleshooting padrão é: conectar-se ao nó, verificar o status do serviço kubelet, olhar os logs para encontrar o erro e, finalmente, corrigir o problema.

### **Parte 1: Diagnosticar o Problema no Nó**

bash

```
# Conecte-se ao nó problemáticossh cluster3-node1
```

bash

```
# Verifique o status do serviço kubelet
systemctl status kubelet
```

A saída mostrará que o serviço está `inactive (dead)` ou em um loop de reinicialização (`activating (auto-restart)`), e indicará uma falha com `code=exited, status=203/EXEC`.

Este erro `203/EXEC` quase sempre significa que o systemd não conseguiu encontrar o arquivo executável especificado no arquivo de serviço.

bash

```
# Verifique os logs do serviço para mais detalhes
journalctl -u kubelet
```

Os logs confirmarão a falha ao tentar executar o binário.

bash

```
# O simulado mostra que o serviço está tentando executar '/usr/local/bin/kubelet'# Vamos verificar onde o binário realmente estáwhereis kubelet
```

A saída mostrará que o caminho correto é `/usr/bin/kubelet`. A causa do problema é um caminho incorreto para o binário do kubelet no arquivo de serviço do systemd.

### **Parte 2: Corrigir o Problema**

Precisamos editar o arquivo de serviço do kubelet para apontar para o caminho correto.

bash

```
# Edite o arquivo de configuração do serviço (o caminho pode variar, mas geralmente está em /etc/systemd/system/ ou /usr/lib/systemd/system/)# O simulado indica o caminho /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.confsudo nano /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
```

Encontre a linha que especifica o `ExecStart` e corrija o caminho de `/usr/local/bin/kubelet` para `/usr/bin/kubelet`.

Salve e feche o arquivo.

bash

```
# Após modificar um arquivo de serviço, é necessário recarregar a configuração do systemdsudo systemctl daemon-reload

# Agora, reinicie o serviço kubeletsudo systemctl restart kubelet
```

### **Parte 3: Escrever o Arquivo de Resposta**

Saia da sessão ssh e crie o arquivo de resposta no seu terminal principal.

bash

```
# Crie o arquivo de respostaecho "wrong path to kubelet binary specified in service config" > /opt/course/18/reason.txt
```

---

### **Verificação Final**

Volte ao seu terminal principal e observe o status do nó. Pode levar um minuto para que ele se atualize.

bash

```
# Observe o status dos nóswatch kubectl get nodes
```

Após um curto período, o status do `cluster3-node1` deve mudar de `NotReady` para `Ready`.

---

### **Conceitos Importantes para a Prova**

- **Troubleshooting de Nós NotReady:** Um nó `NotReady` é um problema comum. O primeiro passo é sempre conectar-se ao nó e verificar o status do serviço kubelet.
- **`systemctl status <serviço>`:** Comando essencial para verificar se um serviço systemd está ativo (`active (running)`) e ver as últimas linhas de log.
- **`journalctl -u <serviço>`:** Comando para visualizar os logs completos de um serviço específico, crucial para encontrar mensagens de erro detalhadas.
- **Erro 203/EXEC:** Um código de erro do systemd que indica que o caminho do executável (`ExecStart`) no arquivo de serviço está incorreto ou o arquivo não tem permissão de execução.
- **`systemctl daemon-reload`:** Comando necessário após editar um arquivo `.service` para que o systemd leia a nova configuração.
- **`systemctl restart <serviço>`:** Reinicia um serviço.

---

# **CKA - Questão 19: Criar e Montar Secrets**

### **Objetivo da Tarefa**

- **Gerenciar Secrets:** Criar `Secrets` a partir de um arquivo YAML e a partir de literais na linha de comando.
- **Montar Secret como Volume:** Disponibilizar os dados de um `Secret` como arquivos dentro de um contêiner.
- **Injetar Secret como Variável de Ambiente:** Expor chaves de um `Secret` como variáveis de ambiente para um contêiner.

A tarefa exige as seguintes ações no contexto `k8s-c3-CCC`, em um novo namespace `secret`:

1. Criar um Pod `secret-pod` (imagem `busybox:1.31.1`) que permaneça em execução.
2. Criar um `Secret` a partir do arquivo `/opt/course/19/secret1.yaml` e montá-lo em modo `read-only` no caminho `/tmp/secret1` dentro do Pod.
3. Criar um novo `Secret` chamado `secret2` com os dados `user=user1` and `pass=1234`.
4. Expor os dados do `secret2` como variáveis de ambiente `APP_USER` e `APP_PASS` dentro do Pod.

---

### **1. Preparando o Ambiente no Lab**

A preparação envolve mudar para o contexto correto e criar o novo namespace.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c3-CCC
```

bash

```
# Crie o namespace 'secret'
kubectl create namespace secret
```

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Criar os Secrets**

Primeiro, crie o `secret1` a partir do arquivo YAML fornecido, certificando-se de adicionar o namespace.

bash

```
# É uma boa prática copiar o arquivo para o diretório local e editá-locp /opt/course/19/secret1.yaml ./
nano secret1.yaml
```

Adicione `namespace: secret` no `metadata` do arquivo.

yaml

```
apiVersion: v1
kind: Secret
metadata:
  name: secret1
  namespace: secret
# ... (restante do arquivo)
```

bash

```
# Crie o secret a partir do arquivo modificado
kubectl apply -f secret1.yaml
```

Agora, crie o `secret2` usando o comando imperativo.

bash

```
# Crie o secret 'secret2' a partir de valores literais
kubectl create secret generic secret2 --from-literal=user=user1 --from-literal=pass=1234 -n secret
```

### **Parte 2: Criar o Pod que Utiliza os Secrets**

Gere um manifesto base e edite-o para adicionar as montagens de volume e as variáveis de ambiente.

bash

```
# Gere o template YAML# 'sleep 1d' garante que o contêiner permaneça em execução
kubectl run secret-pod --image=busybox:1.31.1 -n secret --dry-run=client -o yaml -- /bin/sh -c "sleep 1d" > 19-pod.yaml
```

bash

```
# Edite o arquivo YAMLnano 19-pod.yaml
```

Modifique o arquivo para adicionar as seções `volumes`, `volumeMounts` e `env`:

yaml

```
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
  namespace: secret
spec:
  containers:
  - name: secret-pod
    image: busybox:1.31.1
    command: ["/bin/sh", "-c", "sleep 1d"]
# Injetar secret2 como variáveis de ambienteenv:
    - name: APP_USER
      valueFrom:
        secretKeyRef:
          name: secret2
          key: user
    - name: APP_PASS
      valueFrom:
        secretKeyRef:
          name: secret2
          key: pass
# Montar secret1 como um volumevolumeMounts:
    - name: secret-volume-1
      mountPath: "/tmp/secret1"
      readOnly: true
  volumes:
  - name: secret-volume-1
    secret:
      secretName: secret1
```

bash

```
# Crie o Pod
kubectl apply -f 19-pod.yaml
```

---

### **Verificação Final**

Use `kubectl exec` para entrar no contêiner e verificar se tanto as variáveis de ambiente quanto os arquivos montados estão corretos.

bash

```
# Espere o Pod ficar 'Running'
kubectl get pod -n secret
```

bash

```
# Verifique as variáveis de ambiente
kubectl exec secret-pod -n secret -- env | grep APP_
```

**Saída esperada:**

text

```
APP_USER=user1
APP_PASS=1234
```

bash

```
# Verifique o volume montado
kubectl exec secret-pod -n secret -- ls /tmp/secret1
```

A saída deve listar as chaves do `secret1` como arquivos.

---

### **Conceitos Importantes para a Prova**

- **Secret:** Um objeto Kubernetes usado para armazenar uma pequena quantidade de dados sensíveis, como senhas, tokens ou chaves.
- **Criando Secrets:**
    - **Declarativamente:** A partir de um arquivo YAML. Os dados devem ser codificados em base64.
    - **Imperativamente (`kubectl create secret`):**
        - `generic`: A partir de arquivos (`-from-file`) ou valores literais (`-from-literal`). Os dados são codificados automaticamente.
- **Consumindo Secrets:**
    - **Como Variáveis de Ambiente:** Usando `envFrom` (para todas as chaves) ou `env.valueFrom.secretKeyRef` (para chaves específicas).
    - **Como Volumes:** Usando `volumes.secret.secretName` para definir o volume e `volumeMounts` para montá-lo em um caminho dentro do contêiner. Os dados do secret aparecem como arquivos nesse caminho.

---

# **CKA - Questão 20: Atualizar Versão do Kubernetes e Juntar Nó ao Cluster**

### **Objetivo da Tarefa**

- **Manutenção de Cluster:** Atualizar os componentes do Kubernetes em um nó para a versão correta.
- **Gerenciamento de Cluster com `kubeadm`:** Usar `kubeadm` para gerar um token de junção e adicionar um novo nó de trabalho a um cluster existente.

A tarefa exige as seguintes ações no contexto `k8s-c3-CCC`:

1. O nó `cluster3-node2` está rodando uma versão mais antiga do Kubernetes e não faz parte do cluster.
2. Atualizar os componentes (`kubelet`, `kubectl`, `kubeadm`) no `cluster3-node2` para a mesma versão do nó `cluster3-controlplane1`.
3. Adicionar o nó `cluster3-node2` ao cluster usando `kubeadm join`.

---

### **1. Preparando o Ambiente no Lab**

A preparação envolve identificar a versão alvo e conectar-se ao nó que precisa ser atualizado.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c3-CCC
```

bash

```
# Verifique a versão do control-plane para saber qual é a versão alvo
kubectl get nodes
# Anote a versão (ex: v1.31.1)
```

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Atualizar os Componentes no Nó de Trabalho**

Conecte-se ao nó que precisa ser atualizado.

bash

```
ssh cluster3-node2
```

Verifique as versões atuais.

bash

```
kubelet --version
# A saída mostrará uma versão mais antiga (ex: v1.30.5)
```

Use o gerenciador de pacotes (apt) para instalar a versão exata dos componentes.

bash

```
# Atualize a lista de pacotessudo apt update

# Instale a versão exata do kubelet e kubectl (substitua pela versão alvo)# O formato da versão para o apt é <versão>-<revisão_do_pacote>sudo apt install kubelet=1.31.1-1.1 kubectl=1.31.1-1.1 -y

# Coloque um 'hold' nos pacotes para evitar atualizações automáticas indesejadassudo apt-mark hold kubelet kubectl
```

### **Parte 2: Gerar o Comando de Junção (kubeadm join)**

Esta etapa é executada no nó de control-plane.

bash

```
# Conecte-se ao nó de control-planessh cluster3-controlplane1
```

bash

```
# Gere um novo token e o comando de junção completosudo kubeadm token create --print-join-command
```

Copie a saída inteira do comando, que será algo como: `kubeadm join 192.168.100.31:6443 --token ... --discovery-token-ca-cert-hash sha256:...`

### **Parte 3: Juntar o Nó de Trabalho ao Cluster**

Volte para a sessão ssh do nó de trabalho (`cluster3-node2`) e execute o comando copiado.

bash

```
# Cole e execute o comando 'kubeadm join'sudo kubeadm join 192.168.100.31:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

O processo de junção irá configurar o kubelet e realizar o bootstrap do TLS para que o nó possa se comunicar de forma segura com o api-server.

bash

```
# Após a junção, reinicie e habilite o kubeletsudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl enable kubelet
```

---

### **Verificação Final**

Volte ao seu terminal principal e verifique o status dos nós. Pode levar um ou dois minutos para que o novo nó apareça como `Ready`.

bash

```
# Observe o status dos nóswatch kubectl get nodes
```

A saída deve mostrar o `cluster3-node2` com a versão correta e, eventualmente, com o status `Ready`.

---

### **Conceitos Importantes para a Prova**

- **Atualização de Versão (apt):** Em clusters kubeadm instalados via apt, a atualização dos componentes é feita através do gerenciador de pacotes. É crucial especificar a versão exata para garantir a consistência no cluster.
- **`apt-mark hold`:** Um comando importante para "travar" um pacote em sua versão atual, impedindo que um `apt upgrade` geral o atualize para uma versão incompatível com o cluster.
- **`kubeadm token create`:** Comando executado no control-plane para gerar novos tokens de bootstrap.
- **`-print-join-command`:** Uma flag extremamente útil que formata a saída completa do comando `kubeadm join`, incluindo o token e o hash do CA, pronta para ser copiada e colada no nó de trabalho.
- **`kubeadm join`:** O comando executado em um nó de trabalho para conectá-lo a um cluster Kubernetes existente. Ele usa o token para autenticar-se com o api-server e o hash do certificado da CA para verificar a identidade do control-plane.
