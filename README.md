# WAI - Kubernetes

Il repository contiene gli script di installazione e configurazione di tutte le
componenti infrastrutturali e del software di base della soluzione Web Analitycs
Italia, WAI:

1. Installazione pacchetti software
2. Kubernetes
3. MariaDB con Galera
4. GlusterFS
5. Elasticsearch
6. Immagini docker
7. Script di deployment di Kubernetes

Di seguito l'infrastruttura applicativa e la dislocazione delle componenti.

![Architettura](doc-images/architettura.jpg)

Per la descrizione della infrastruttura fare riferimento alla documentazione
consultabile a questo [link]() ed al capacity plan presente a questo [link]().

## Requisiti

Installare le dipendenze con:

```bash
$ pip install -r requirements.txt
```

Per l'installazione è necessario utilizzare un host locale o remoto come
**controller**; su questa macchina è necessario creare la chiave RSA per
l'accesso tramite ssh utilizzando il comando prestando attenzione a non indicare
alcuna *passphrase*.:

```bash
$ ssh-keygen -t rsa -b 4096
```
Il comando creerà una copia di chiavi (pubblica e privata) che saranno
utilizzate per l'accesso agli host dell'infrastruttura.

## Provisioning

Per il provisioning dell'infrastruttura presso il servizio SPC Cloud - Lotto 1,
è disponibile lo script `infrastructure/wai-provisioner.py` che automatizza la
procedura di creazione di tutte le risorse previste (reti, gruppi di protezione,
istanze, volumi, etc.).

Prima di utilizzare lo script è necessario creare i file che descrivono gli
ambienti utilizzado i template disponibili
(`infrastructure/env-*.tfvars.template`) e copiandoli/rinominandoli senza
l'estensione `.template`.

Nel file `env-common.tfvars` va inserita la chiave **pubblica** generata
precedentemente.

Le credenziali per l'accesso al cloud provider devono essere caricate come
variabili d'ambiente. Il modo più semplice è utilizzare il [file _OpenStack
RC_](https://docs.openstack.org/newton/user-guide/common/cli-set-environment-variables-using-openstack-rc.html#download-and-source-the-openstack-rc-file).

Se non si desidera utilizzare lo script è possibile usare direttamente
[Terraform](https://www.terraform.io/) avendo cura di creare tre distinti
workspace per ciascuno degli ambienti previsti: `production`, `staging` e
`public-playground`.

### Utilizzo

Per la creazione/aggiornamento delle risorse nell'infrastruttura:

```bash
$ infrastructure/wai-provisioner.py <environment> apply
```

Per la distruzione delle risorse nell'infrastruttura (senza possibilità di
recupero):

```bash
$ infrastructure/wai-provisioner.py <environment> destroy
```

Il parametro `<environment>` può assumere uno dei tre valori: `production`,
`staging` o `public-playground`.

## Ansible

Per l'installazione e configurazione del software di base e delle componenti
infrastrutturali è stato realizzato il playbook
[Ansible](https://www.ansible.com/) `wai.yml`; il playbook è realizzato per la
versione del sistema operativo Ubuntu Server 18.04 LTS.

### Inventory dinamico

Lo script `playbooks/inventory/10-openstack_inventory.py` è utilizzato da
Ansible per la generazione di un inventory dinamico a partire dalle risorse
create. Accanto a questo è presente anche un inventory statico
(`playbooks/inventory/20-k8s-static-inventory`) necessario per l'installazione
del cluster Kubernetes.

Anche questo script necessita che le credenziali per l'accesso al cloud provider
siano caricate come variabili d'ambiente.

L'inventory è selezionato automaticamente mediante la configurazione di ansible
presente nel file `playbooks/ansible.cfg`, quindi non è necessario specificarlo
nella riga di comando.

### Ruoli e playbook esterni

Prima di lanciare il playbook è necessario installare i ruoli relativi
all'installazione di
[Elasticsearch](https://www.elastic.co/products/elasticsearch):

```bash
$ ansible-galaxy install elastic.elasticsearch,6.6.0
```

L'installazione del cluster [Kubernetes](https://kubernetes.io/) è effettuata
mediante il playbook esterno
[kubespray](https://github.com/kubernetes-sigs/kubespray) che deve essere quindi
clonato dal suo repository:

```bash
$ git clone --branch v2.10.4 https://github.com/kubernetes-sigs/kubespray.git playbooks/kubespray
```

### Ruoli

Il playbook per l'installazione di Web Analytics Italia contiene i seguenti
ruoli:

- *infrastructure*: Utilizzato per alcuni task di preparazione degli host;
- *elastic.elasticsearch*: Installazione di Elasticsearch tramite i ruoli
  installati con `ansible-galaxy`;
- *kibana*: Installazione di [Kibana](https://www.elastic.co/products/kibana);
- *metricbeat*: Installazione di
  [Metricbeat](https://www.elastic.co/products/beats/metricbeat);
- *glusterfs*: Installazione di [GlusterFS](https://www.gluster.org/)
  **DA ULTIMARE CONFIGURAZIONE PEER**
- *mariadb*: Installazione di [MariaDB](https://mariadb.com/)
  **DA ULTIMARE PARAMETRI DI STARTUP**
- *galera*: Configurazione dei due cluster [Galera](https://galeracluster.com/)
  per produzione e public-playground **DA FARE**
- *kubernetes*: Installazione del cluster di
  [Kubernetes](https://kubernetes.io/) con il playbook esterno
  [kubespray](https://github.com/kubernetes-sigs/kubespray)

### Tags

Il playbook contiene anche i seguenti tag:

- *check*: per i controlli iniziali sui requisiti;
- *install*: relativo all'installazione di tutto il software in tutti e tre gli
  ambienti;
- *production*: relativo all'installazione nel solo ambiente *production*;
- *staging*: relativo all'installazione nel solo ambiente *staging*;
- *public-playground*: relativo all'installazione nel solo ambiente
  *public-playground*;
- *deploy*: relativo al deploy del database *Matomo* e di tutte le risorse
  *Kubernetes*;
- *matomo*: relativo al deploy del solo database *Matomo*;
- *kubernetes-deploy*: relativo al deploy di tutte le risorse *Kubernetes*;

### Parametri

TODO: Indicare i parametri da modificare

#### Password

Il playpook per il deploy dell'infrastruttura e la configurazione del software
di base utilizza`ansible-vault` per l'archiviazione delle password . Il file
`password.yml` contiene le credenziali relative a:

- utenti di *Matomo*;
- database;
- *Redis*;

Decriptare il file `password.yml`, utilizzando la password *changeme* con il
comando:

```bash
$ ansible-vault decrypt playbooks/password.yml
```

Impostare le password all'interno del file e crittografare nuovamente il file
con il comando:

```bash
$ ansible-vault encrypt playbooks/password.yml
```

### Esecuzione Playbook

```bash
$ cd playbooks
$ ansible-playbook wai.yml -b --ask-vault-pass --limit 'wai'
```

## Immagini docker

TODO: *Breve descrizione e link all'md di dettaglio*

### Redis

TODO: *Breve descrizione e link all'md di dettaglio*

#### Sentinel

TODO: *Breve descrizione e link all'md di dettaglio*

### Matomo

TODO: *Breve descrizione e link all'md di dettaglio*

#### Base Matomo

TODO: *Breve descrizione e link all'md di dettaglio*

#### Matomo Portal

TODO: *Breve descrizione e link all'md di dettaglio*

#### Matomo Ingestion

TODO: *Breve descrizione e link all'md di dettaglio*

#### Matomo API

TODO: *Breve descrizione e link all'md di dettaglio*

#### Matomo Worker

TODO: *Breve descrizione e link all'md di dettaglio*

#### Matomo Cron Job

TODO: *Breve descrizione e link all'md di dettaglio*

### WAI

TODO: *Breve descrizione e link all'md di dettaglio*

#### WAI Portal

TODO: *Breve descrizione e link all'md di dettaglio*

#### WAI API

TODO: *Breve descrizione e link all'md di dettaglio*

#### WAI Cron Job

TODO: *Breve descrizione e link all'md di dettaglio*

## Deployment Kubernetes

TODO: *Breve descrizione e link all'md di dettaglio*
