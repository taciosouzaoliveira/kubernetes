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
