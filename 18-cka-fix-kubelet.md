# **CKA - Questão 18: Consertar o Kubelet**

### **Objetivo da Tarefa**

- **Troubleshooting de Nó:** Diagnosticar e resolver um problema que impede um nó de se juntar ao cluster, especificamente um `kubelet` que não inicia.
- **Análise de Serviços `systemd`:** Usar `systemctl` e `journalctl` para inspecionar o status e os logs de um serviço de sistema.
- **Corrigir Configurações:** Identificar e corrigir um erro de configuração em um arquivo de serviço do `systemd`.

A tarefa exige as seguintes ações no contexto `k8s-c3-CCC`:

1. O nó `cluster3-node1` está em estado `NotReady`.
2. Diagnosticar o motivo pelo qual o `kubelet` não está rodando corretamente no nó.
3. Corrigir o problema para que o `kubelet` inicie e o nó mude para o estado `Ready`.
4. Escrever a causa do problema no arquivo `/opt/course/18/reason.txt`.

---

### **1. Preparando o Ambiente no Lab**

A preparação consiste em mudar para o contexto correto e observar o estado inicial dos nós.

bash

```
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c3-CCC
```

bash

```
# Verifique o status dos nós. 'cluster3-node1' deve estar 'NotReady'.
kubectl get nodes
```

---

### **2. Resolvendo a Questão: Passo a Passo**

O fluxo de troubleshooting padrão é: conectar-se ao nó, verificar o status do serviço kubelet, olhar os logs para encontrar o erro e, finalmente, corrigir o problema.

### **Parte 1: Diagnosticar o Problema no Nó**

bash

```
# Conecte-se ao nó problemáticossh cluster3-node1
```

bash

```
# Verifique o status do serviço kubelet
systemctl status kubelet
```

A saída mostrará que o serviço está `inactive (dead)` ou em um loop de reinicialização (`activating (auto-restart)`), e indicará uma falha com `code=exited, status=203/EXEC`.

Este erro `203/EXEC` quase sempre significa que o systemd não conseguiu encontrar o arquivo executável especificado no arquivo de serviço.

bash

```
# Verifique os logs do serviço para mais detalhes
journalctl -u kubelet
```

Os logs confirmarão a falha ao tentar executar o binário.

bash

```
# O simulado mostra que o serviço está tentando executar '/usr/local/bin/kubelet'# Vamos verificar onde o binário realmente estáwhereis kubelet
```

A saída mostrará que o caminho correto é `/usr/bin/kubelet`. A causa do problema é um caminho incorreto para o binário do kubelet no arquivo de serviço do systemd.

### **Parte 2: Corrigir o Problema**

Precisamos editar o arquivo de serviço do kubelet para apontar para o caminho correto.

bash

```
# Edite o arquivo de configuração do serviço (o caminho pode variar, mas geralmente está em /etc/systemd/system/ ou /usr/lib/systemd/system/)# O simulado indica o caminho /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.confsudo nano /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
```

Encontre a linha que especifica o `ExecStart` e corrija o caminho de `/usr/local/bin/kubelet` para `/usr/bin/kubelet`.

Salve e feche o arquivo.

bash

```
# Após modificar um arquivo de serviço, é necessário recarregar a configuração do systemdsudo systemctl daemon-reload

# Agora, reinicie o serviço kubeletsudo systemctl restart kubelet
```

### **Parte 3: Escrever o Arquivo de Resposta**

Saia da sessão ssh e crie o arquivo de resposta no seu terminal principal.

bash

```
# Crie o arquivo de respostaecho "wrong path to kubelet binary specified in service config" > /opt/course/18/reason.txt
```

---

### **Verificação Final**

Volte ao seu terminal principal e observe o status do nó. Pode levar um minuto para que ele se atualize.

bash

```
# Observe o status dos nóswatch kubectl get nodes
```

Após um curto período, o status do `cluster3-node1` deve mudar de `NotReady` para `Ready`.

---

### **Conceitos Importantes para a Prova**

- **Troubleshooting de Nós NotReady:** Um nó `NotReady` é um problema comum. O primeiro passo é sempre conectar-se ao nó e verificar o status do serviço kubelet.
- **`systemctl status <serviço>`:** Comando essencial para verificar se um serviço systemd está ativo (`active (running)`) e ver as últimas linhas de log.
- **`journalctl -u <serviço>`:** Comando para visualizar os logs completos de um serviço específico, crucial para encontrar mensagens de erro detalhadas.
- **Erro 203/EXEC:** Um código de erro do systemd que indica que o caminho do executável (`ExecStart`) no arquivo de serviço está incorreto ou o arquivo não tem permissão de execução.
- **`systemctl daemon-reload`:** Comando necessário após editar um arquivo `.service` para que o systemd leia a nova configuração.
- **`systemctl restart <serviço>`:** Reinicia um serviço.
