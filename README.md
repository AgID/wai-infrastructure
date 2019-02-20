# WAI - Kubernetes

Il repository contiene gli script di installazione e configurazione di tutte le componenti infrastrutturali e del software di base della soluzione Web Analitycs Italia, WAI:

1. Installazione pacchetti software
2. Kubernetes
3. MariaDB con Galera
4. GlusterFS
5. Elasticsearch
6. Immagini docker
7. Script di deployment di Kubernetes

Di seguito l'infrastruttura applicativa e la dislocazione delle componenti.

 ![Architettura](doc-images/architettura.jpg)

Per la descrizione della infrastruttura fare riferimento alla documentazione consultabile a questo [link]() ed al capacity plan presente a questo [link]().

## Ansible

Per l'installazione e configurazione del software di base e delle componenti infrastrutturali è stato realizzato il playbook  Ansible *wai.yml*; il playbook è realizzato per la versione del sistema operativo installato ovvero Ubuntu 18.x.

### Prerequisiti
Per l'installazione è necessario utilizzare un host remoto come **controller**; su questa macchina è necessario, per prima cosa, creare la chiave RSA per l'accesso tramite ssh utilizzando il comando prestando attenzione a non indicare alcuna *passphrase*.:
```bash
$ ssh-keygen
```
Il comando creerà una copia di chiavi (chiave pubblica e privata) che generalmente sono memorizzate in ~/.ssh 

Generata la chiave è necessario installare sul **controller** ansible ed alcuni pacchetti python:
```bash
$ chmod +x install_3pp.sh
$ sudo install_3pp.sh
```
Dopo aver installato i prerequisiti sul **controller** installare alcuni ruoli di ansible :
```bash
$ ansible-galaxy install elastic.elasticsearch
```
### Ruoli
Il playbook per l'installazione di Web Analytics Italia contiene i seguenti ruoli:

1. *infrastructure*: Utilizzato per lo scambio della chiave RSA del controller con tutti i server e l'abilitazione di sudo senza password per l'utente remoto;
2. *elastic.elasticsearch*: Installazione di Elasticsearch tramite i ruoli installati con `ansible-galaxy install elastic.elasticsearch`;
3. *kibana*: Installazione di kibana;
4. *metricbeat*: Installazione di Metricbeat abilitando solamente il modulo system;
5. *glusterfs*: Installazione di GlusterFS **DA ULTIMARE CONFIGURAZIONE PEER**
6. *mariadb*: Installazione di MariaDB **DA ULTIMARE PARAMETRI DI STARTUP**
7. *galera*: Configurazione dei due cluster Galera per produzione e public play ground **DA FARE**
8. *kubernetes*: Installazione del cluster di kubernetes con [kubespray](https://github.com/kubernetes-sigs/kubespray)

### Review Inventory

TODO: Indicazioni per l'inventoty

### Parametri

TODO: Indicare i parametri da modificare

### Inizializzazione

Disabilitare il controllo della chiave per i server dell'infrastruttura eseguendo il seguente comando

```bash
$ cat > ~/.ansible.cfg <<EOF
[defaults]
host_key_checking = False
roles_path = $(pwd)/ansible/kubespray-2.8.3
EOF
```

### Esecuzione Playbook

Impostare all'interno del file ansible/group_vars/all.yml le variabili *ansible_user* e *ansible_ssh_password* con il nome dell'utente e la password che saranno utilizzate per il collegamento ai server dell'infrastruttura.

Configurato l'utente siamo pronti per eseguire il playbook tramite il comando
```bash
$ cd ansible
$ ansible-playbook -i hosts.ini wai.yml -b -K
```


## Immagini docker
*Breve descrizione e link all'md di dettaglio*
### Redis
*Breve descrizione e link all'md di dettaglio*
#### Redis
*Breve descrizione e link all'md di dettaglio*
#### Sentinel
*Breve descrizione e link all'md di dettaglio*
### Matomo
*Breve descrizione e link all'md di dettaglio*
#### Base Matomo
*Breve descrizione e link all'md di dettaglio*
#### Matomo Portal
*Breve descrizione e link all'md di dettaglio*
#### Matomo Ingestion
*Breve descrizione e link all'md di dettaglio*
#### Matomo API
*Breve descrizione e link all'md di dettaglio*
#### Matomo Worker
*Breve descrizione e link all'md di dettaglio*
#### Matomo Cron Job
*Breve descrizione e link all'md di dettaglio*
### WAI
*Breve descrizione e link all'md di dettaglio*
#### WAI Portal
*Breve descrizione e link all'md di dettaglio*
#### WAI API
*Breve descrizione e link all'md di dettaglio*
#### WAI Cron Job
*Breve descrizione e link all'md di dettaglio*
## Deployment Kubernetes
*Breve descrizione e link all'md di dettaglio*
