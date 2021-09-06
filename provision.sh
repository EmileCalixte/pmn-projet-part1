#!/bin/sh

# Paranoia mode
set -e
set -u

# Je récupere le hostname du serveur
HOSTNAME="$(hostname)"

# Je définis le contenu du fichier de configuration SSH
SSH_CONFIG=$(cat << 'EOF'
Host s0.infra
        User vagrant
        Hostname 192.168.50.20
        IdentityFile ~/.ssh/ansible_deploy_nopass_rsa

Host s1.infra
        User vagrant
        Hostname 192.168.50.30
        IdentityFile ~/.ssh/ansible_deploy_nopass_rsa

Host s2.infra
        User vagrant
        Hostname 192.168.50.40
        IdentityFile ~/.ssh/ansible_deploy_nopass_rsa

Host s3.infra
        User vagrant
        Hostname 192.168.50.50
        IdentityFile ~/.ssh/ansible_deploy_nopass_rsa

Host s4.infra
        User vagrant
        Hostname 192.168.50.60
        IdentityFile ~/.ssh/ansible_deploy_nopass_rsa
EOF
)

apt-get --allow-releaseinfo-change update

# J'installe des outils pré-requis
apt-get install -y \
  unzip

if [ "$HOSTNAME" = "control" ]; then
  # Je mets à jour les sources pour pouvoir installer une version plus récente d'ansible
  echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu bionic main" | tee -a /etc/apt/sources.list
  apt-get install -y gnupg2
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
  apt-get update

	# J'installe ansible dessus
  apt-get install -y \
		ansible

	# J'installe la collection ansible mysql
	ansible-galaxy collection install community.mysql

  # Je configure SSH pour l'utilisateur vagrant
  cd /home/vagrant/.ssh
  cp /vagrant/ansible_deploy_nopass_rsa .
  chmod 600 ansible_deploy_nopass_rsa
  touch config
  echo "$SSH_CONFIG" > config
  chown -R vagrant:vagrant /home/vagrant/.ssh

  # Je configure SSH pour l'utilisateur root
  cd /root
  mkdir -p .ssh
  cd .ssh
  cp /vagrant/ansible_deploy_nopass_rsa .
  chmod 600 ansible_deploy_nopass_rsa
  touch config
  echo "$SSH_CONFIG" > config

else
  # Je configure SSH pour l'utilisateur vagrant
  cd /home/vagrant/.ssh
  cp /vagrant/ansible_deploy_nopass_rsa.pub .
  cat ansible_deploy_nopass_rsa.pub >> authorized_keys
  chown -R vagrant:vagrant /home/vagrant/.ssh

  # Je configure SSH pour l'utilisateur root
  cd /root
  mkdir -p .ssh
  cd .ssh
  cp /vagrant/ansible_deploy_nopass_rsa.pub .
  cat ansible_deploy_nopass_rsa.pub >> authorized_keys
fi

if [ "$HOSTNAME" = "s3.infra" ]; then
	apt-get install -y \
		python-pip

	python2.7 -m pip install -U pip
	python2.7 -m pip install -U setuptools
	apt-get install -y python-dev libpq-dev
	pip install pymysql
fi
