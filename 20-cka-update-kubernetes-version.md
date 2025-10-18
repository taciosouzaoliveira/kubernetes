### **Arquivo: `20-cka-update-kubernetes-version.md`**

```markdown
# CKA - Questão 20: Atualizar Versão do Kubernetes e Juntar Nó ao Cluster

### Objetivo da Tarefa

-   **Manutenção de Cluster:** Atualizar os componentes do Kubernetes em um nó para a versão correta.
-   **Gerenciamento de Cluster com `kubeadm`:** Usar `kubeadm` para gerar um token de junção e adicionar um novo nó de trabalho a um cluster existente.

A tarefa exige as seguintes ações no contexto `k8s-c3-CCC`:
1.  O nó `cluster3-node2` está rodando uma versão mais antiga do Kubernetes e não faz parte do cluster.
2.  Atualizar os componentes (`kubelet`, `kubectl`, `kubeadm`) no `cluster3-node2` para a mesma versão do nó `cluster3-controlplane1`.
3.  Adicionar o nó `cluster3-node2` ao cluster usando `kubeadm join`.

---

### 1. Preparando o Ambiente no Lab

A preparação envolve identificar a versão alvo e conectar-se ao nó que precisa ser atualizado.

```bash
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c3-CCC
Bash

# Verifique a versão do control-plane para saber qual é a versão alvo
kubectl get nodes
# Anote a versão (ex: v1.31.1)
2. Resolvendo a Questão: Passo a Passo
Parte 1: Atualizar os Componentes no Nó de Trabalho
Conecte-se ao nó que precisa ser atualizado.

Bash

ssh cluster3-node2
Verifique as versões atuais.

Bash

kubelet --version
# A saída mostrará uma versão mais antiga (ex: v1.30.5)
Use o gerenciador de pacotes (apt) para instalar a versão exata dos componentes.

Bash

# Atualize a lista de pacotes
sudo apt update

# Instale a versão exata do kubelet e kubectl (substitua pela versão alvo)
# O formato da versão para o apt é <versão>-<revisão_do_pacote>
sudo apt install kubelet=1.31.1-1.1 kubectl=1.31.1-1.1 -y

# Coloque um 'hold' nos pacotes para evitar atualizações automáticas indesejadas
sudo apt-mark hold kubelet kubectl
Parte 2: Gerar o Comando de Junção (kubeadm join)
Esta etapa é executada no nó de control-plane.

Bash

# Conecte-se ao nó de control-plane
ssh cluster3-controlplane1
Bash

# Gere um novo token e o comando de junção completo
sudo kubeadm token create --print-join-command
Copie a saída inteira do comando, que será algo como: kubeadm join 192.168.100.31:6443 --token ... --discovery-token-ca-cert-hash sha256:...

Parte 3: Juntar o Nó de Trabalho ao Cluster
Volte para a sessão ssh do nó de trabalho (cluster3-node2) e execute o comando copiado.

Bash

# Cole e execute o comando 'kubeadm join'
sudo kubeadm join 192.168.100.31:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
O processo de junção irá configurar o kubelet e realizar o bootstrap do TLS para que o nó possa se comunicar de forma segura com o api-server.

Bash

# Após a junção, reinicie e habilite o kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl enable kubelet
Verificação Final
Volte ao seu terminal principal e verifique o status dos nós. Pode levar um ou dois minutos para que o novo nó apareça como Ready.

Bash

# Observe o status dos nós
watch kubectl get nodes
A saída deve mostrar o cluster3-node2 com a versão correta e, eventualmente, com o status Ready.

Conceitos Importantes para a Prova
Atualização de Versão (apt): Em clusters kubeadm instalados via apt, a atualização dos componentes é feita através do gerenciador de pacotes. É crucial especificar a versão exata para garantir a consistência no cluster.

apt-mark hold: Um comando importante para "travar" um pacote em sua versão atual, impedindo que um apt upgrade geral o atualize para uma versão incompatível com o cluster.

kubeadm token create: Comando executado no control-plane para gerar novos tokens de bootstrap.

--print-join-command: Uma flag extremamente útil que formata a saída completa do comando kubeadm join, incluindo o token e o hash do CA, pronta para ser copiada e colada no nó de trabalho.

kubeadm join: O comando executado em um nó de trabalho para conectá-lo a um cluster Kubernetes existente. Ele usa o token para autenticar-se com o api-server e o hash do certificado da CA para verificar a identidade do control-plane.
