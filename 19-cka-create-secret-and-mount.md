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
