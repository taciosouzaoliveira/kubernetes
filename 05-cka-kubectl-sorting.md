# CKA - Questão 5: Ordenação com Kubectl

### Objetivo da Tarefa

-   **Formatação de Saída:** Usar a funcionalidade de ordenação do `kubectl` para listar recursos com base em campos específicos de seus metadados.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:
1.  Criar um script em `/opt/course/5/find_pods.sh` que liste todos os Pods de todos os namespaces, ordenados por sua data de criação (`metadata.creationTimestamp`).
2.  Criar um segundo script em `/opt/course/5/find_pods_uid.sh` que liste todos os Pods de todos os namespaces, ordenados por seu UID (`metadata.uid`).

---

### 1. Preparando o Ambiente no Lab

A única preparação necessária é mudar para o contexto correto e criar o diretório de destino.

```bash
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
Bash

# Crie o diretório para a solução
sudo mkdir -p /opt/course/5
2. Resolvendo a Questão: Passo a Passo
A solução utiliza a flag --sort-by do kubectl get.

Parte 1: Script para Ordenar por Data de Criação
Bash

# Cria o script usando 'echo' e redirecionamento
echo "kubectl get pods -A --sort-by=.metadata.creationTimestamp" > /opt/course/5/find_pods.sh

# Adiciona permissão de execução
chmod +x /opt/course/5/find_pods.sh
Parte 2: Script para Ordenar por UID
Bash

# Cria o segundo script
echo "kubectl get pods -A --sort-by=.metadata.uid" > /opt/course/5/find_pods_uid.sh

# Adiciona permissão de execução
chmod +x /opt/course/5/find_pods_uid.sh
Verificação Final
Execute os scripts para confirmar que eles produzem a saída ordenada corretamente.

Bash

# Execute o primeiro script
sh /opt/course/5/find_pods.sh
A saída será uma lista de todos os Pods, com os mais antigos aparecendo primeiro.

Bash

# Execute o segundo script
sh /opt/course/5/find_pods_uid.sh
A saída será uma lista de todos os Pods, ordenados alfanumericamente por seu UID.

Conceitos Importantes para a Prova
kubectl get -A: A flag -A (ou --all-namespaces) é um atalho para listar recursos de todos os namespaces.

--sort-by: Uma flag poderosa do kubectl get que permite ordenar a saída com base em um campo do objeto, usando a sintaxe jsonpath.

JSONPath: Uma linguagem de expressão para selecionar partes de um documento JSON (ou, neste caso, a representação YAML/JSON de um objeto Kubernetes).

O . no início (.metadata...) indica que o caminho começa na raiz do objeto.

metadata.creationTimestamp: Um campo padrão em todos os objetos Kubernetes que registra quando o objeto foi criado.

metadata.uid: Um identificador único universal (UUID) gerado pelo sistema para cada objeto criado.

