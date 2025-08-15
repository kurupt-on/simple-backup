#!/bin/bash

check_user(){
	[ "$( id -u )" -ne 0 ] && echo "Execute como root" && exit 1 
}

welcome(){
	clear
	echo "Script para criação de Backups simples."
	echo 
}

menu_config(){
	echo "Escolha um diretório local para os seu backups. (Padrão é $PWD/backup)"
	read -p "Destino: " LOCALDIR_BKP
	echo "Informe os arquivos e/ou diretórios para compactação"
	read -p "Arquivos: " FILES_TO_BKP
	echo "Nome do arquivo  (Padrão é bkp-YY-MM-DD-nnnnnnnnn.tar)" 
	read -p "Nome: " BKP_NAME
	read -p "Informe o algoritmo de compactação: (Padrão é nenhum) " ZIP_ON 
	read -p "Fazer sincronização de diretórios? [y p/ sim] " RSYNC_ON

	[ "$RSYNC_ON" == "y" ] && read -p "Informe o diretório destino dos backups: " DEST_BKP 
	[ -z "$LOCALDIR_BKP" ] && [ ! -d "$PWD/backup" ] && mkdir "$PWD/backup" 
	[ -d "$PWD/backup" ] && LOCALDIR_BKP="$PWD/backup"
	[ -z "$BKP_NAME" ] && BKP_NAME="bkp-$( date +%F-%N ).tar"

	case "$ZIP_ON" in
		gzip|gz)
			TYPE_ZIP="z"
			ZIP_EXTENSION=".gz"
			;;
		bzip2|bz2)
		
			TYPE_ZIP="j"
			ZIP_EXTENSION=".bz2"
			;;
		xzip|xz)
			TYPE_ZIP="J"
			ZIP_EXTENSION=".xz"
			;;
		"")
			TYPE_ZIP=""
			ZIP_EXTENSION=""
			;;
		*)
			echo "Algoritmo não suportado."
			exit 1
			;;
	esac
}

zip_test(){
	if [ "$TYPE_ZIP" == "j" ]; then
		[ ! -f "/usr/bin/bzip2" ] && echo "Binário do bzip2 não encontrado" && echo "Atualizando a lista de pacotes." && apt update -y &>/dev/null
		[ "$?" -eq 0 ] && echo "Baixando os pacotes necessários." && apt install -y bzip2 &>/dev/null
	else
		[ ! -f "/usr/bin/xz" ] && echo "Binário do xz não encontrado" && echo "Atualizando a lista de pacotes." && apt update -y &>/dev/null
		[ "$?" -eq 0 ] && echo "Baixando os pacotes necessários." && apt install -y xz-utils &>/dev/null
	fi
}

exec_tar(){
	echo "Iniciando a compactação."

	PATH_LAST_BKP="$LOCALDIR_BKP/$BKP_NAME"
	echo "$FILES_TO_BKP"
	tar -c"$TYPE_ZIP"f "$PATH_LAST_BKP$ZIP_EXTENSION" $FILES_TO_BKP  

	[ "$?" -eq 0 ] && echo "Backup feito com sucesso!"
	echo
}

exec_rsync(){
	rsync -av "$LOCALDIR_BKP" "$DEST_BKP" 
}

welcome
menu_config
zip_test
exec_tar
[ -z "$DEST_BKP" ] || exec_rsync
