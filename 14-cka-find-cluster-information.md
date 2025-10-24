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
