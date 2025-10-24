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
