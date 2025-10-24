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
