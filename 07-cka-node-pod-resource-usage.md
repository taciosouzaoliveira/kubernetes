### **Arquivo: `07-cka-node-pod-resource-usage.md`**
```markdown
# CKA - Questão 7: Uso de Recursos de Nós e Pods

### Objetivo da Tarefa

-   **Monitoramento de Recursos:** Utilizar os comandos `kubectl top` para visualizar o consumo de CPU e memória de Nós e Pods.
-   **Metrics Server:** Entender que `kubectl top` depende do `metrics-server` para funcionar.

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:
1.  Escrever o comando que mostra o uso de recursos dos **Nós** do cluster no arquivo `/opt/course/7/node.sh`.
2.  Escrever o comando que mostra o uso de recursos dos **Pods e de seus contêineres individuais** no arquivo `/opt/course/7/pod.sh`.

---

### 1. Preparando o Ambiente no Lab

A preparação consiste em mudar para o contexto correto e garantir que o `metrics-server` está instalado e funcionando.

```bash
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
Bash

# Verifique se o metrics-server está rodando no namespace kube-system
kubectl get pods -n kube-system | grep metrics-server
Se o Pod estiver em estado "Running", o kubectl top deve funcionar.

Bash

# Crie o diretório para a solução
sudo mkdir -p /opt/course/7
2. Resolvendo a Questão: Passo a Passo
A solução utiliza o comando kubectl top com diferentes subcomandos e flags.

Parte 1: Script para Uso de Recursos dos Nós
Bash

# Cria o script usando 'echo' e redirecionamento
echo "kubectl top node" > /opt/course/7/node.sh

# Adiciona permissão de execução
chmod +x /opt/course/7/node.sh
Parte 2: Script para Uso de Recursos de Pods e Contêineres
Para ver os contêineres individuais, usamos a flag --containers.

Bash

# Cria o segundo script
echo "kubectl top pod -A --containers=true" > /opt/course/7/pod.sh

# Adiciona permissão de execução
chmod +x /opt/course/7/pod.sh
Nota: Adicionamos a flag -A (--all-namespaces) para garantir que todos os Pods de todos os namespaces sejam exibidos, o que é uma prática comum.

Verificação Final
Execute os scripts para confirmar que eles produzem a saída esperada.

Bash

# Execute o script para ver o uso de recursos dos nós
sh /opt/course/7/node.sh
A saída será uma tabela com os nomes dos nós e seu consumo atual de CPU (em cores) e memória (em bytes).

Bash

# Execute o script para ver o uso de recursos dos pods e contêineres
sh /opt/course/7/pod.sh
A saída será uma tabela listando cada Pod e, para cada um, os contêineres que rodam dentro dele com seus respectivos consumos de CPU e memória.

Conceitos Importantes para a Prova

kubectl top: O comando principal para visualizar métricas de consumo de recursos em tempo real. 


kubectl top node: Subcomando específico para exibir o uso de CPU e memória de cada nó no cluster. 



kubectl top pod: Subcomando para exibir o uso de CPU e memória dos Pods. 



--containers=true: Flag que expande a saída para mostrar o consumo de cada contêiner individualmente dentro de cada Pod. 

Metrics Server: Um componente crucial do cluster que coleta métricas de consumo de recursos dos kubelets em cada nó e as expõe através da API de Métricas do Kubernetes. O kubectl top consome dados dessa API. Sem o metrics-server funcionando, o comando kubectl top retornará um erro. 

