Arquivo: 09-cka-manual-scheduling.md
Markdown

# CKA - Questão 9: Agendamento Manual de Pods

### Objetivo da Tarefa

-   **Gerenciar Componentes do Control Plane:** Parar e reiniciar o `kube-scheduler` para observar seu impacto no cluster.
-   **Entender o Processo de Agendamento:** Simular o papel do scheduler agendando manualmente um Pod em um nó específico.
-   **Manipular Manifestos de Pod:** Editar o manifesto YAML de um Pod para atribuí-lo a um nó.

A tarefa exige as seguintes ações no contexto `k8s-c2-AC`:
1.  Conectar-se ao `cluster2-controlplane1` e **parar temporariamente** o `kube-scheduler`.
2.  Criar um Pod `manual-schedule` (imagem `httpd:2.4-alpine`) e confirmar que ele permanece no estado `Pending`.
3.  Agendar manualmente este Pod para rodar no nó `cluster2-controlplane1`.
4.  Reiniciar o `kube-scheduler`.
5.  Criar um segundo Pod `manual-schedule2` e confirmar que ele é agendado automaticamente pelo scheduler em um nó de trabalho (`cluster2-node1`).

---

### 1. Preparando o Ambiente no Lab

A única preparação é conectar-se ao nó de `control-plane`.

```bash
# Mude para o contexto do cluster correto
kubectl config use-context k8s-c2-AC
Bash

# Conecte-se ao nó de control-plane
ssh cluster2-controlplane1
2. Resolvendo a Questão: Passo a Passo
Parte 1: Parar o Kube-Scheduler
Em um cluster kubeadm, o scheduler roda como um static pod. Para pará-lo temporariamente, basta mover seu manifesto para fora do diretório /etc/kubernetes/manifests.

Bash

# Mova o manifesto do scheduler para um local temporário (ex: /root)
mv /etc/kubernetes/manifests/kube-scheduler.yaml /root/
Após alguns segundos, o kubelet detectará a ausência do arquivo e removerá o Pod do scheduler.

Verificação:

Bash

kubectl get pod -n kube-system | grep scheduler
# (O comando não deve retornar nenhum Pod)
Parte 2: Criar um Pod e Confirmar o Estado Pending
Volte para o seu terminal principal para criar o Pod.

Bash

# Crie o Pod
kubectl run manual-schedule --image=httpd:2.4-alpine
Bash

# Verifique seu status. A coluna NODE estará <none> e o STATUS será Pending.
kubectl get pod manual-schedule -o wide
Parte 3: Agendar o Pod Manualmente
Para agendar o Pod, precisamos editar seu manifesto YAML e adicionar o campo spec.nodeName.

Bash

# Obtenha o YAML do Pod e salve em um arquivo
kubectl get pod manual-schedule -o yaml > 09-pod.yaml
Bash

# Edite o arquivo
nano 09-pod.yaml
Adicione a linha nodeName: cluster2-controlplane1 dentro da seção spec:

YAML

apiVersion: v1
kind: Pod
# ... (metadados)
spec:
  nodeName: cluster2-controlplane1   # Adicionar esta linha
  containers:
  # ... (resto da especificação)
Como não podemos editar um Pod em execução dessa forma, precisamos deletá-lo e recriá-lo a partir do arquivo modificado.

Bash

# --force --grace-period=0 deleta o Pod imediatamente
kubectl delete pod manual-schedule --force --grace-period=0
Bash

# Crie o Pod a partir do manifesto modificado
kubectl apply -f 09-pod.yaml
Verificação:

Bash

# O Pod agora deve estar Running no nó de control-plane
kubectl get pod manual-schedule -o wide
Nota: O Pod é agendado no control-plane mesmo sem tolerations porque, ao definir o nodeName manualmente, nós contornamos a lógica de agendamento do scheduler, que é quem avalia os taints.

Parte 4: Reiniciar o Scheduler e Testar
Volte para a sessão SSH no control-plane e mova o manifesto do scheduler de volta para seu lugar.

Bash

# Mova o arquivo de volta para o diretório de manifestos
mv /root/kube-scheduler.yaml /etc/kubernetes/manifests/
O kubelet detectará o arquivo e iniciará o Pod do scheduler novamente.

Verificação Final: No seu terminal principal, crie o segundo Pod e verifique onde ele é agendado.

Bash

# Crie o segundo Pod
kubectl run manual-schedule2 --image=httpd:2.4-alpine
Bash

# Aguarde alguns segundos e verifique onde os Pods estão rodando
kubectl get pods -o wide | grep manual-schedule
A saída deve mostrar manual-schedule rodando no cluster2-controlplane1 e manual-schedule2 rodando em um nó de trabalho, como cluster2-node1, confirmando que o scheduler está funcionando.

Conceitos Importantes para a Prova
Parando Static Pods: A maneira de parar/iniciar um static pod é mover seu manifesto para fora ou para dentro do diretório /etc/kubernetes/manifests.

O Papel do Scheduler: A principal função do kube-scheduler é observar Pods que não têm um nó (spec.nodeName está vazio) e, com base em filtros e prioridades (recursos, taints, afinidade), escolher o melhor nó e atualizar o spec.nodeName do Pod.

Agendamento Manual: Ao definir o campo spec.nodeName diretamente no manifesto de um Pod, você está efetivamente fazendo o trabalho do scheduler e forçando o kubelet daquele nó específico a executar o Pod.

Agendamento Manual e Taints: O agendamento manual ignora os taints do nó, pois o scheduler (que é quem os verifica) não está envolvido no processo.

