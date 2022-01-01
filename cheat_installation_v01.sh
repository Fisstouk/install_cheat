#!/bin/bash
#
#version: 1.0
#
#

clear

#affiche chaque commande effectuee
#set -x

#arrete le programme apres un retour different de 0
#set -e

clear

function user_root()
{
	if [ "$(id -u)" != "0" ]; then
		echo "Ce script doit être lancé avec root" 1>&2
		exit 1
	fi
}

function update()
{
	apt update && apt upgrade -y
	apt install sudo vim tree htop mlocate rsync -y
}

function cheat_download()
{
	apt install git -y
	wget https://github.com/cheat/cheat/releases/download/4.2.3/cheat-linux-amd64.gz
	gunzip cheat-linux-amd64.gz
	
	#ajouter les droits d'execution a tous les utilisateurs
	chmod a+x cheat-linux-amd64
	
	#deplacer vers /usr/local/bin/cheat
	mv -v cheat-linux-amd64 /usr/local/bin/cheat
}

function cheat_dir()
{
	#creation manuelle des dossiers
	mkdir -vp /opt/COMMUN/cheat/cheatsheets/personal
	mkdir -v /opt/COMMUN/cheat/cheatsheets/community
}

function config_cheat()
{
	#création du fichier yaml
	cheat --init > /opt/COMMUN/cheat/conf.yml

	#remplacement du dossier de root par défaut vers /opt/COMMUN
	sed -i 's;/root/.config/; /opt/COMMUN/;' /opt/COMMUN/cheat/conf.yml

	#téléchargement des cheatsheets de la communauté
	git clone https://github.com/cheat/cheatsheets.git

	#déplacement de tous les cheatsheets texte vers le nouveau dossier dans /opt/COMMUN/cheat/cheatsheets/community/
	find /root/cheatsheets/ -type f -execdir mv -t /opt/COMMUN/cheat/cheatsheets/community {} +
}

function rights_cheat()
{
	#creation du groupe commun
	groupadd commun

	#changer les droits de /opt/COMMUN pour que ce repertoire appartienne au grp commun
	chgrp -Rv commun /opt/COMMUN

	#setgid de 2 donc tous les fichiers appartiennent au grp commun
	chmod 2770 /opt/COMMUN
}


function dir_root()
{
	#umask de 007 repertoires et fichiers
	echo 'umask 007' >> /root/.bashrc

	#creer le fichier de conf de root
	mkdir /root/.config/

	#creer le fichier de conf pour tous les users grace a skel
	mkdir /etc/skel/.config/

	#ajout de ll au bashrc et skel pour tous les utilisateurs
	echo 'alias ll="ls -rtl --color"' >> /root/.bashrc	

	#alias chmod
	echo 'alias chmod="chmod -v --preserve-root"' >> /root/.bashrc

	#alias mv
	echo 'alias mv="mv -vi"' >> /root/.bashrc

	#alias rm
	echo 'alias rm="rm -rv --preserve-root"' >> /root/.bashrc

	#alias su
	echo 'alias su="su -"' >> /root/.bashrc

	#alias min5: afficher les fichiers du repertoire courant
	#qui ont ete modifie il y a moins de 5 min et les afficher
	echo 'alias min5="find . -type f -mmin -5 -ls"' >> /root/.bashrc

	#personnaliser le PS1
	echo 'export PS1="\n[\t] \u@\h \w\n\$ "' >> /root/.bashrc
	source /root/.bashrc

	#lien symbolique qui nous mene a /opt/COMMUN/cheat 
	ln -s /opt/COMMUN/cheat /root/.config/cheat

	#lien symbolique de /etc/skel/.config/cheat qui nous mene vers /opt/COMMUN/cheat
	ln -s /opt/COMMUN/cheat /etc/skel/.config/cheat

	#ajout du droit d'écriture pour le groupe commun
	chmod g+sw /opt/COMMUN/cheat/cheatsheets/personal/

}

function user_lyronn()
{
	#ajout au groupe sudo et commun
	usermod -aG sudo,commun lyronn

	#umask de 007 repertoires et fichiers
	echo 'umask 007' >> /home/lyronn/.bashrc

	#creation du fichier .config et de cheat
	mkdir -v /home/lyronn/.config/

	#.config appartient seulement a lyronn
	chown -Rv lyronn /home/lyronn/.config

	#lien symbolique vers opt/commun/cheat pour la gestion de cheat par l'admin
	ln -s /opt/COMMUN/cheat/ /home/lyronn/.config/cheat

	#ajouter vim comme editeur par defaut
	echo 'export VISUAL=vim' >> /home/lyronn/.bashrc
	echo 'export EDITOR="$VISUAL"' >> /home/lyronn/.bashrc

	#ajout de ll au bashrc et skel pour tous les utilisateurs
	echo 'alias ll="ls -rtl --color"' >> /home/lyronn/.bashrc	

	#alias chmod
	echo 'alias chmod="chmod -v --preserve-root"' >> /home/lyronn/.bashrc

	#alias mv
	echo 'alias mv="mv -vi"' >> /home/lyronn/.bashrc

	#alias rm
	echo 'alias rm="rm -rv --preserve-root"' >> /home/lyronn/.bashrc

	#alias su
	echo 'alias su="su -"' >> /home/lyronn/.bashrc

	#alias min5: afficher les fichiers du repertoire courant
	#qui ont ete modifie il y a moins de 5 min et les afficher
	echo 'alias min5="find . -type f -mmin -5 -ls"' >> /home/lyronn/.bashrc

	#personnaliser le PS1
	echo 'export PS1="\n[\t] \u@\h \w\n\$ "' >> /home/lyronn/.bashrc
	source /home/lyronn/.bashrc
}

function user_esgi()
{
	#creer le user esgi 
	#-G group -s shell -m home directory -c commentaire
	useradd -G sudo,commun -s /bin/bash -m -c 'Compte du prof' esgi

	#creer le mdp
	#echo -e 'Pa55w.rd' | sudo passwd esgi
	echo esgi:Pa55w.rd | chpasswd

	#.config appartient seulement a esgi
	chown -Rv esgi /home/esgi/.config

	#lien symbolique vers opt/commun/cheat pour la gestion de cheat par l'admin
	ln -s /opt/COMMUN/cheat/ /home/esgi/.config/cheat

	#ajouter vim comme editeur par defaut
	echo 'export VISUAL=vim' >> /home/esgi/.bashrc
	echo 'export EDITOR="$VISUAL"' >> /home/esgi/.bashrc

	#ajouter le umask 007 pour les repertoires et fichiers
	echo 'umask 007' >> /home/esgi/.bashrc

	#ajout de ll au bashrc et skel pour tous les utilisateurs
	echo 'alias ll="ls -rtl --color"' >> /home/esgi/.bashrc	

	#alias chmod
	echo 'alias chmod="chmod -v --preserve-root"' >> /home/esgi/.bashrc

	#alias mv
	echo 'alias mv="mv -vi"' >> /home/esgi/.bashrc

	#alias rm
	echo 'alias rm="rm -rv --preserve-root"' >> /home/esgi/.bashrc

	#alias su
	echo 'alias su="su -"' >> /home/esgi/.bashrc

	#alias min5: afficher les fichiers du repertoire courant
	#qui ont ete modifie il y a moins de 5 min et les afficher
	echo 'alias min5="find . -type f -mmin -5 -ls"' >> /home/esgi/.bashrc

	#personnaliser le PS1
	echo 'export PS1="\n[\t] \u@\h \w\n\$ "' >> /home/esgi/.bashrc
	source /home/esgi/.bashrc
	su -
}

echo "Vérification de l'utilisateur root"
user_root

sleep 15

echo "Mise à jour du système"
echo "Installation de sudo, vim, tree, htop, mlocate et rsync"
update

sleep 15

echo "Téléchargement de cheat"
cheat_download

sleep 15

echo "Création des dossiers personal et community"
cheat_dir

sleep 15

echo "Initialisation de cheat"
echo "Téléchargements et déplacement des cheatsheets de la communauté"
echo "Création des fichiers de conf dans /root/.config/cheat et /etc/skel/.config/cheat"
config_cheat

sleep 15

echo "Droits pour cheat"
rights_cheat

sleep 15

echo "Configuration de root"
dir_root

sleep 15

echo "Configuration de l'utilisateur lyronn"
user_lyronn

sleep 15
echo "Configuration de l'utilisateur esgi"
user_esgi

