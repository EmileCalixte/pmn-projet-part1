#!/bin/sh

# Paranoia mode
set -e
set -u

# Je récupere le hostname du serveur
HOSTNAME="$(hostname)"

if [ "$HOSTNAME" = "control" ]; then
	# J'installe ansible dessus
	apt-get install -y \
		ansible

fi
