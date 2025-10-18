# CKA - Questão 17: Encontrar Contêiner de um Pod e Verificar Informações

### Objetivo da Tarefa

-   **Interação Nó-Contêiner:** Entender a relação entre um `Pod` do Kubernetes e o contêiner real que roda no nó.
-   **Uso de `crictl`:** Utilizar a ferramenta de linha de comando `crictl` para interagir diretamente com o `container runtime` do nó (ex: `containerd`).

A tarefa exige as seguintes ações no contexto `k8s-c1-H`:
1.  No namespace `project-tiger`, criar um Pod `tigers-reunite` (imagem `httpd:2.4.41-alpine`) com labels `pod=container` e `container=pod`.
2.  Descobrir em qual nó o Pod foi agendado e conectar-se a ele via `ssh`.
3.  No nó, usar `crictl` para encontrar o contêiner correspondente ao Pod.
4.  Escrever o ID do contêiner e o `info.runtimeType` em `/opt/course/17/pod-container.txt`.
5.  Escrever os logs do contêiner em `/opt/course/17/pod-container.log`.

---

### 1. Preparando o Ambiente no Lab

A preparação consiste em mudar para o contexto correto e criar o diretório de destino.

```bash
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
Bash

# Crie o diretório para a solução
sudo mkdir -p /opt/course/17
2. Resolvendo a Questão: Passo a Passo
Parte 1: Criar o Pod e Encontrar seu Nó
Bash

# Crie o Pod com os labels especificados
kubectl run tigers-reunite --image=httpd:2.4.41-alpine --labels="pod=container,container=pod" -n project-tiger
Bash

# Espere o Pod ficar 'Running' e use '-o wide' para ver em qual nó ele está
kubectl get pod tigers-reunite -n project-tiger -o wide
# Anote o nome do nó (ex: cluster1-node2)
Parte 2: Encontrar o Contêiner e Extrair Informações
Conecte-se ao nó onde o Pod está rodando e use crictl.

Bash

# Conecte-se ao nó (substitua pelo nome do nó correto)
ssh <node-name>
Bash

# Use 'crictl ps' para listar os contêineres e 'grep' para encontrar o que pertence ao nosso Pod
crictl ps | grep tigers-reunite
# Anote o CONTAINER ID (ex: b01edbe6f89ed)
Bash

# Use 'crictl inspect' para obter os detalhes do contêiner e filtre pelo runtimeType
crictl inspect <container-id> | grep runtimeType
# Saída esperada: "runtimeType": "io.containerd.runc.v2"
Parte 3: Escrever os Arquivos de Resposta
Saia da sessão ssh e crie os arquivos de resposta no seu terminal principal.

Bash

# Crie o primeiro arquivo com o ID e o runtimeType
echo "b01edbe6f89ed io.containerd.runc.v2" > /opt/course/17/pod-container.txt
Volte ao nó para coletar os logs.

Bash

# Conecte-se novamente ao nó
ssh <node-name>
Bash

# Use 'crictl logs' e redirecione a saída para o arquivo de destino no seu terminal principal
# Isso pode ser feito em um único comando, mas para o exame, copiar e colar pode ser mais simples.
crictl logs <container-id>
# Copie a saída e cole no arquivo local:
# nano /opt/course/17/pod-container.log
Uma maneira mais avançada de fazer isso em um passo:

Bash

ssh <node-name> "crictl logs <container-id>" &> /opt/course/17/pod-container.log
Verificação Final
Verifique o conteúdo dos arquivos criados para garantir que eles contêm as informações corretas.

Bash

cat /opt/course/17/pod-container.txt
cat /opt/course/17/pod-container.log
Conceitos Importantes para a Prova
crictl: A ferramenta de linha de comando padrão para depurar e inspecionar o Container Runtime Interface (CRI). Ela permite interagir diretamente com o runtime (como containerd ou CRI-O) em um nó, de forma independente do kubelet.

Relação Pod-Contêiner: Um Pod do Kubernetes é uma abstração. A entidade real que executa o código é o contêiner (containerd, docker, etc.) no nó. Saber como fazer essa ligação é crucial para troubleshooting de baixo nível.

Comandos crictl:

crictl ps: Lista os contêineres em execução no nó (semelhante a docker ps).

crictl inspect: Fornece um JSON detalhado sobre um contêiner (semelhante a docker inspect).

crictl logs: Exibe os logs de um contêiner (semelhante a docker logs).

Container Runtime: O software responsável por executar os contêineres. O Kubernetes interage com ele através do CRI. containerd é o runtime padrão na maioria das instalações modernas.

