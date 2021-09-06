# pmn-projet-part1

## Procédure de tests

### Démarrage

Sur votre machine locale :
```bash
vagrant up
```

Pour se connecter aux différentes machines :
```bash
vagrant ssh <nom>
```

Avec :
- `control` : Machine de contrôle Ansible
- `s0.infra` : Load balancer (frontend web)
- `s1.infra` et s2.infra : Serveurs web
- `s3.infra` : Serveur de base de données
- `s4.infra` : Serveur de fichiers (NFS)

Se connecter à la machine control pour exécuter les playbooks, avec la commande `vagrant ssh control`

Exécuter les commandes suivantes pour exécuter les playbooks Ansible :

```bash
cd /vagrant
ansible-playbook -i inventories/default playbook-setup-nfs.yml
ansible-playbook -i inventories/default playbook-setup-webservers.yml
ansible-playbook -i inventories/default playbook-setup-db.yml
ansible-playbook -i inventories/default playbook-install-wordpress.yml
ansible-playbook -i inventories/default playbook-setup-loadbalancer.yml
```

Pour vérifier le bon fonctionnement des serveurs web et du load balancer, exécuter sur la machine s0 :

```bash
curl -L devops.com
```

Pour faire ces tests depuis la machine locale, ajouter dans le fichier `hosts` :
```
127.0.0.1 devops.com
127.0.0.1 devsec.com
127.0.0.1 devsecops.com
```

Via un navigateur web, constater que les serveurs web répondent aux requêtes sur ces noms de domaine.

### Supprimer une machine

Sur la machine locale, exécuter la commande suivante pour supprimer un des deux serveurs web :

```bash
vagrant destroy s1.infra
```

Constater dans un navigateur web (ou via CURL) que le load balancer continue à délivrer le site web uniquement via le serveur web qui fonctionne toujours.