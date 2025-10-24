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
