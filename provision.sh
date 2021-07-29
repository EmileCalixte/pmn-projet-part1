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

# J'installe des outils pré-requis
apt-get install -y \
  unzip

if [ "$HOSTNAME" = "control" ]; then
	# J'installe ansible dessus
  apt-get install -y \
		ansible

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
