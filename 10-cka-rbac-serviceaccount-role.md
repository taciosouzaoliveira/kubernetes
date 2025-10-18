### **Arquivo: `10-cka-rbac-serviceaccount-role.md`**

```markdown
# CKA - Questão 10: RBAC com ServiceAccount, Role e RoleBinding

### Objetivo da Tarefa

-   **RBAC (Role-Based Access Control):** Entender e criar os principais recursos do RBAC para conceder permissões a uma conta de serviço dentro de um namespace específico.
-   **Criar ServiceAccount:** Criar uma identidade para um processo que roda dentro de um Pod.
-   **Criar Role e RoleBinding:** Definir um conjunto de permissões (`Role`) e associá-lo a um `ServiceAccount` (`RoleBinding`).

A tarefa exige as seguintes ações no contexto `k8s-c1-H`, dentro do namespace `project-hamster`:
1.  Criar um novo `ServiceAccount` chamado `processor`.
2.  Criar uma `Role` chamada `processor` que conceda permissão para **apenas criar** (`create`) os recursos `Secrets` e `ConfigMaps`.
3.  Criar uma `RoleBinding` chamada `processor` que associe a `Role` criada ao `ServiceAccount` criado.

---

### 1. Preparando o Ambiente no Lab

A preparação consiste em mudar para o contexto correto e garantir que o namespace existe.

```bash
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c1-H
Bash

# Verifique se o namespace existe (o simulado assume que sim)
kubectl get ns project-hamster
2. Resolvendo a Questão: Passo a Passo
A solução envolve criar os três recursos em sequência usando comandos imperativos kubectl create.

Parte 1: Criar o ServiceAccount
Bash

# Sintaxe: kubectl create serviceaccount <nome> -n <namespace>
kubectl create serviceaccount processor -n project-hamster
Parte 2: Criar a Role
O comando kubectl create role permite definir as permissões de forma imperativa.

Bash

# Sintaxe: kubectl create role <nome> --verb=<verbo> --resource=<recurso> -n <namespace>
# Podemos adicionar múltiplos verbos ou recursos
kubectl create role processor --verb=create --resource=secrets --resource=configmaps -n project-hamster
Parte 3: Criar a RoleBinding
O RoleBinding conecta o "sujeito" (ServiceAccount) ao conjunto de permissões (Role).

Bash

# Sintaxe: kubectl create rolebinding <nome> --role=<nome_da_role> --serviceaccount=<namespace>:<nome_do_sa> -n <namespace>
kubectl create rolebinding processor --role=processor --serviceaccount=project-hamster:processor -n project-hamster
Verificação Final
Use o comando kubectl auth can-i para verificar se as permissões foram aplicadas corretamente. Este comando simula uma ação como se fosse o ServiceAccount.

Bash

# Teste se o SA pode criar um secret (deve retornar "yes")
kubectl auth can-i create secret --as=system:serviceaccount:project-hamster:processor -n project-hamster

# Teste se o SA pode criar um configmap (deve retornar "yes")
kubectl auth can-i create configmap --as=system:serviceaccount:project-hamster:processor -n project-hamster

# Teste se o SA pode criar um pod (deve retornar "no")
kubectl auth can-i create pod --as=system:serviceaccount:project-hamster:processor -n project-hamster

# Teste se o SA pode deletar um secret (deve retornar "no")
kubectl auth can-i delete secret --as=system:serviceaccount:project-hamster:processor -n project-hamster
Conceitos Importantes para a Prova
RBAC: O mecanismo padrão do Kubernetes para controlar o acesso à API. Baseia-se em quatro objetos principais.

ServiceAccount: Fornece uma identidade para processos que rodam dentro de um Pod.

Role: Um conjunto de permissões (regras) que se aplica a um único namespace. Cada regra define verbos (get, list, create, delete) que podem ser executados em um conjunto de recursos (pods, secrets).

ClusterRole: Semelhante a uma Role, mas suas permissões são válidas para o cluster inteiro.

RoleBinding: Conecta um Role a um "sujeito" (User, Group, ou ServiceAccount), concedendo as permissões da Role àquele sujeito dentro do namespace da RoleBinding.

ClusterRoleBinding: Conecta um ClusterRole a um sujeito, concedendo as permissões em todo o cluster.

kubectl auth can-i: Uma ferramenta de depuração extremamente útil para verificar se um determinado usuário ou ServiceAccount tem permissão para realizar uma ação.

--as: Flag para personificar outro usuário ou conta de serviço.

Sintaxe do SA: system:serviceaccount:<namespace>:<nome_do_sa>.

Arquivo: 11-cka-daemonset-on-all-nodes.md
Markdown

