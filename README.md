# WAI - Kubernetes

[![Build Status](https://travis-ci.com/AgID/wai-infrastructure.svg?branch=develop)](https://travis-ci.com/AgID/wai-infrastructure)

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
l'accesso tramite ssh utilizzando il comando:

```bash
$ ssh-keygen -t rsa -b 4096 -N '' -f ssh_wai_key
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

Prima di lanciare il playbook è necessario installare alcuni ruoli tra cui
quello relativo all'installazione di
[Elasticsearch](https://www.elastic.co/products/elasticsearch):

```bash
$ ansible-galaxy install -r playbooks/requirements.yml
```

L'installazione del cluster [Kubernetes](https://kubernetes.io/) è effettuata
mediante il playbook esterno
[kubespray](https://github.com/kubernetes-sigs/kubespray) che deve essere quindi
clonato dal suo repository:

```bash
$ git clone --branch v2.12.0 https://github.com/kubernetes-sigs/kubespray.git playbooks/kubespray
```

### Ruoli

Il playbook per l'installazione di Web Analytics Italia contiene i seguenti
ruoli:

- _infrastructure_: Utilizzato per alcuni task di preparazione degli host;
- _elastic.elasticsearch_: Installazione di Elasticsearch tramite i ruoli
  installati con `ansible-galaxy`;
- _kibana_: Installazione di [Kibana](https://www.elastic.co/products/kibana);
- _glusterfs_: Installazione di [GlusterFS](https://www.gluster.org/)
  **DA ULTIMARE CONFIGURAZIONE PEER**
- _mariadb_: Installazione di [MariaDB](https://mariadb.com/)
  **DA ULTIMARE PARAMETRI DI STARTUP**
- _galera_: Configurazione dei due cluster [Galera](https://galeracluster.com/)
  per produzione e public-playground **DA FARE**
- _kubernetes_: Installazione del cluster di
  [Kubernetes](https://kubernetes.io/) con il playbook esterno
  [kubespray](https://github.com/kubernetes-sigs/kubespray)

### Tags

Il playbook contiene anche i seguenti tag:

- _check_: per i controlli iniziali sui requisiti;
- _install_: relativo all'installazione di tutto il software in tutti e tre gli
  ambienti;
- _production_: relativo all'installazione nel solo ambiente _production_;
- _staging_: relativo all'installazione nel solo ambiente _staging_;
- _public-playground_: relativo all'installazione nel solo ambiente
  _public-playground_;
- _deploy_: relativo al deploy del database _Matomo_ e di tutte le risorse
  _Kubernetes_;
- _matomo_: relativo al deploy del solo database _Matomo_;
- _kubernetes-deploy_: relativo al deploy di tutte le risorse _Kubernetes_;

Per generare in ambiente locale tutti i file relativi alle risorse K8S si può
usare il tag _templates_:

```bash
$ ansible-playbook playbooks/wai.yml -i playbooks/inventory/30-localhost -t templates
```

### Parametri

TODO: Indicare i parametri da modificare

#### Password

Il playbook per il deploy dell'infrastruttura e la configurazione del software
di base utilizza il file `secrets.yml` per leggere tutti i parametri che vanno
tenuti segreti per motivi di sicurezza.

Per condividere il file `secrets.yml`, è possibile utilizzare `ansible-vault`.

Dopo aver impostato i parametri all'interno del file, si può criptare con il
comando:

```bash
$ ansible-vault encrypt playbooks/secrets.yml
```

Decriptare il file `secrets.yml`, utilizzando la password impostata con il
comando:

```bash
$ ansible-vault decrypt playbooks/secrets.yml
```

### Esecuzione Playbook

Prima dell'esecuzione del playbook è possibile verificare la raggiungibilità di
tutti gli host presenti nell'inventory con il comando:

```bash
$ ansible all -m ping --limit 'wai'
```

Per eseguire il playbook:

```bash
$ ansible-playbook playbooks/wai.yml -b --ask-vault-pass --limit 'wai'
```

## Immagini docker

TODO: _Breve descrizione e link all'md di dettaglio_

### Redis

TODO: _Breve descrizione e link all'md di dettaglio_

#### Sentinel

TODO: _Breve descrizione e link all'md di dettaglio_

### Matomo

TODO: _Breve descrizione e link all'md di dettaglio_

#### Base Matomo

TODO: _Breve descrizione e link all'md di dettaglio_

#### Matomo Portal

TODO: _Breve descrizione e link all'md di dettaglio_

#### Matomo Ingestion

TODO: _Breve descrizione e link all'md di dettaglio_

#### Matomo API

TODO: _Breve descrizione e link all'md di dettaglio_

#### Matomo Worker

TODO: _Breve descrizione e link all'md di dettaglio_

#### Matomo Cron Job

TODO: _Breve descrizione e link all'md di dettaglio_

### WAI

TODO: _Breve descrizione e link all'md di dettaglio_

#### WAI Portal

TODO: _Breve descrizione e link all'md di dettaglio_

#### WAI API

TODO: _Breve descrizione e link all'md di dettaglio_

#### WAI Cron Job

TODO: _Breve descrizione e link all'md di dettaglio_

## Deployment Kubernetes

TODO: _Breve descrizione e link all'md di dettaglio_
