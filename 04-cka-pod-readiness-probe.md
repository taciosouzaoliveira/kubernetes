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
