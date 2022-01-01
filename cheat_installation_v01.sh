#!/bin/bash
#
#prenom: Lyronn
#version: 0.4
#
#

clear

#affiche chaque commande effectuee
set -x

#arrete le programme apres un retour different de 0
set -e

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
	sed -i 's;/root/.config/; opt/COMMUN/;' /opt/COMMUN/cheat/conf.yml

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

	#personnaliser le PS1
	export PS1='\n[\t] \u@\h \w\n\$ '

	#lien symbolique qui nous mene a /opt/COMMUN/cheat 
	ln -s /opt/COMMUM/cheat /root/.config/cheat

	#lien symbolique de /etc/skel/.config/cheat qui nous mene vers /opt/COMMUN/cheat
	ln -s /opt/COMMUN/cheat /etc/skel/.config/cheat

}

function user_lyronn()
{
	#creation du groupe commun
	groupadd commun

	#ajout au groupe sudo et commun
	usermod -aG sudo 
	usermod -aG commun

	#umask de 007 repertoires et fichiers
	umask 007

	#creation du fichier de config cheat
	mkdir /home/lyronn/.config/cheat	

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

	#personnaliser le PS1
	export PS1='\n[\t] \u@\h \w\n\$ '
}

function user_esgi()
{
	#creer le user esgi 
	#-G group -s shell -m home directory -c commentaire
	useradd -G sudo -s /bin/bash -m -c 'Compte du prof' esgi

	#creer le mdp
	echo -e 'Pa55w.rd' | sudo passwd esgi

	#ajouter au groupe sudo et commun
	usermod -aG sudo 
	usermod -aG commun

	#creation du fichier de config cheat
	mkdir /home/esgi/.config/cheat	

	#lien symbolique vers opt/commun/cheat pour la gestion de cheat par l'admin
	ln -s /opt/COMMUN/cheat/ /home/esgi/.config/cheat

	#ajouter vim comme editeur par defaut
	echo 'export VISUAL=vim' >> /home/esgi/.bashrc
	echo 'export EDITOR="$VISUAL"' >> /home/esgi/.bashrc

	#ajouter le umask 007 pour les repertoires et fichiers
	umask 007

	#ajout de ll au bashrc et skel pour tous les utilisateurs
	echo 'alias ll="ls -rtl --color"' >> /home/esgi/.bashrc	

	#alias chmod
	echo 'alias chmod="chmod -v --preserve-root"' >> /home/esgi/.bashrc

	#alias mv
	echo 'alias mv="mv -vi"' >> /home/esgi/.bashrc

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
