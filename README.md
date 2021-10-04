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

Exécuter les commandes suivantes pour exécuter les playbooks Ansible (le mot de passe du vault est `vault_secret`) :

```bash
cd /vagrant
ansible-playbook -i inventories/default playbook-setup-nfs.yml
ansible-playbook -i inventories/default playbook-setup-webservers.yml
ansible-playbook -i inventories/default playbook-setup-db.yml --ask-vault-pass
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

### Configuration de la base de données

Pour faire fonctionner wordpress, utiliser les valeurs de connexion à la base de données suivantes :
- Database Name :
  - `devops_com` pour devops.com
  - `devsec_com` pour devsec.com
  - `devsecops_com` pour devsecops.com
- Username : `wordpress`
- Password : `SuperSecr3t` (il s'agit du mot de passe chiffré via Ansible Vault)
- Database Host : `s3.infra`

### Tests

Sur la machine locale, exécuter la commande suivante pour supprimer un des deux serveurs web :

```bash
vagrant destroy s1.infra
```

Constater dans un navigateur web (ou via CURL) que le load balancer continue à délivrer le site web uniquement via le serveur web qui fonctionne toujours.

Sur la machine locale, exécuter les commandes suivantes pour supprimer le second serveur web et le proxy :

```bash
vagrant destroy s0.infra
vagrant destroy s2.infra
```

Constater dans un navigateur web (ou via CURL) que les sites ne sont plus accessibles.

Sur la machine locale, exécuter la commande suivante pour relancer les machines et réexécuter les playbooks :

```bash
vagrant up s0.infra s1.infra s2.infra
```

Réexécuter les commandes de playbooks sur la machine `control`, puis constater que les sites sont à nouveau accessibles.