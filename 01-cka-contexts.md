# **CKA - Questão 1: Contextos e Configuração do Kubectl**

### **Objetivo da Tarefa**

- **Inspecionar Configuração:** Listar os contextos `kubectl` disponíveis.
- **Criar Scripts:** Gerar scripts para exibir o contexto atual, um usando `kubectl` e outro manipulando o arquivo de configuração diretamente.

A tarefa exige as seguintes ações:

1. Escrever os nomes de todos os contextos `kubectl` disponíveis no arquivo `/opt/course/1/contexts`.
2. Criar um script em `/opt/course/1/context_default_kubectl.sh` que exiba o nome do contexto atual usando o comando `kubectl`.
3. Criar um segundo script em `/opt/course/1/context_default_no_kubectl.sh` que exiba o nome do contexto atual **sem** usar `kubectl`.

---

### **1. Preparando o Ambiente no Lab**

A única preparação necessária é garantir que o diretório de destino para os arquivos de solução exista.

### **1.1 Criar o Diretório de Destino**

bash

```
# Crie o diretório para a soluçãosudo mkdir -p /opt/course/1
```

---

### **2. Resolvendo a Questão: Passo a Passo**

### **Parte 1: Listar Todos os Contextos**

O comando `kubectl config get-contexts` pode ser usado com a opção `-o name` para listar apenas os nomes.

bash

```
# Redireciona a lista de nomes de contextos para o arquivo de destino
kubectl config get-contexts -o name > /opt/course/1/contexts
```

### **Parte 2: Criar Script com kubectl**

O subcomando `current-context` foi feito exatamente para isso.

bash

```
# Cria o script usando o comando 'echo' e o redirecionamento '>'echo "kubectl config current-context" > /opt/course/1/context_default_kubectl.sh

# Adiciona permissão de execução (boa prática)chmod +x /opt/course/1/context_default_kubectl.sh
```

### **Parte 3: Criar Script sem kubectl**

O contexto atual está definido no arquivo `~/.kube/config`. Podemos usar ferramentas de texto como `grep` e `sed` para extrair a informação.

bash

```
# Cria o script que lê o arquivo, filtra a linha e remove o prefixoecho "grep 'current-context:' ~/.kube/config | sed 's/current-context: //'" > /opt/course/1/context_default_no_kubectl.sh

# Adiciona permissão de execuçãochmod +x /opt/course/1/context_default_no_kubectl.sh
```

---

### **Verificação Final**

Execute os scripts e verifique o conteúdo dos arquivos para confirmar que a solução está correta.

bash

```
# Verifique a lista de contextoscat /opt/course/1/contexts
```

**Saída esperada:**

text

```
k8s-c1-H
k8s-c2-AC
k8s-c3-CCC
```

bash

```
# Teste o primeiro scriptsh /opt/course/1/context_default_kubectl.sh
```

bash

```
# Teste o segundo scriptsh /opt/course/1/context_default_no_kubectl.sh
```

Ambos os scripts devem retornar o nome do contexto atual.

---

### **Conceitos Importantes para a Prova**

- **`kubectl config`:** O principal comando para visualizar e gerenciar a configuração do kubectl, incluindo contextos, clusters e usuários.
- **`get-contexts`:** Subcomando para listar os contextos. A flag `o name` é útil para scripting.
- **`current-context`:** Subcomando para exibir rapidamente o nome do contexto ativo.
- **`~/.kube/config`:** O arquivo YAML padrão que armazena toda a configuração do kubectl. Saber sua estrutura básica é útil para troubleshooting.
- **Shell Tools (`grep`, `sed`):** Ferramentas essenciais para manipular texto na linha de comando, muito úteis na prova para filtrar saídas.
