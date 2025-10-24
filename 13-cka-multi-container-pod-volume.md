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
