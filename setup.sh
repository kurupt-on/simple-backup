#!/bin/bash

OPTINAL_ON=0
OPTINAL_ON=0
DEFAULT_ON=0
SHOW_RSYNC=0
RSYNC_ON=0
BKP_NAME="bkp.$( date +%F-%N ).tar"
PATH_DIR_BKP="$PWD/backup/"
FULL_PATH="$PATH_DIR_BKP$BKP_NAME"
EXCLUDE_VALUE=""

check_user(){
	[ "$( id -u )" -ne 0 ] && echo "Execute como root" && exit 1 
}

select_compress(){
	while true; do
		clear
		echo "Algoritmo de compressão."
		echo
		echo "[R]eset		->	Reseta o valor e volta para o menu principal."
		echo
		echo "Selecione um:"
		echo "[j]   ->   bzip2"
		echo "[J]   ->   xzip"
		echo "[z]   ->   gzip"
		echo
		read -p ": " TYPE_ZIP
		case "$TYPE_ZIP" in
			z)
				ZIP_EXTENSION=".gz"
				ZIP_NAME="gzip"
				break
				;;
			j)
				ZIP_EXTENSION=".bz2"
				ZIP_NAME="bzip2"
				break
				;;
			J)
				ZIP_EXTENSION=".xz"
				ZIP_NAME="xz"
				break
				;;
			R)
				TYPE_ZIP=""
				ZIP_EXTENSION=""
				break
				;;
			*)
				clear
				echo "Opção inválida."
				sleep 1
				;;
		esac
	done
}

select_destiny(){
	while true; do
		clear
		echo "Caminho do backup."
		echo
		echo "FULL PATH = $PATH_DIR_BKP$BKP_NAME"
		echo
		echo "[F]inish	->	Finaliza e volta para o menu principal."
		echo "[R]eset 	->	Reseta para o caminho completo padrão."
		echo "[N]ame		->	Define somente o nome do arquivo."
		echo "[D]ir		->	Define somente o diretório local dos backups."
		echo "[S]et		->	Define o caminho completo."
		echo
		read -p ": " SET_PATH
		case "$SET_PATH" in
			F)
				FULL_PATH="$PATH_DIR_BKP$BKP_NAME"
				break
				;;
			R)
				PATH_DIR_BKP="$PWD/backup/"
				BKP_NAME="bkp.$( date +%F-%N ).tar"
				FULL_PATH="$PWD/backup/bkp.$( date +%F-%N ).tar"
				;;
			N)
				read -p "Nome: " BKP_NAME
				;;
			D)
				OLP_PATH_DIR_BKP=$PATH_DIR_BKP
				read -p "Diretório: " PATH_DIR_BKP
				[ "$PATH_DIR_BKP" == "/" ] && clear && echo "Utilizar o "/" não é permitido." && sleep 2 && PATH_DIR_BKP=$OLP_PATH_DIR_BKP
				;;
			S)
				read -p "Caminho completo: " FULL_PATH
				BKP_NAME="$( basename $FULL_PATH )"
				PATH_DIR_BKP="$( dirname $FULL_PATH )/"
				;;
			*)
				clear
				echo "Opção inválida."
				sleep 1
				;;
		esac
	done
}

select_archives(){
	while true; do
		clear
		echo "Arquivos para backup."
		echo
		echo "[F]inish	->	Finaliza e volta para o meu principal."
		echo "[R]eset		->	Reseta o valor."
		echo "[S]et		->	Define os arquivos para backup."
		echo
		echo "Arquivos = $FILES_TO_BKP"
		echo
		read -p ": " SET_FILES
		case "$SET_FILES" in
			R)
				FILES_TO_BKP=""
				;;
			F)
				break
				;;
			S)
				read -p "Arquivos: " FILES_TO_BKP
				;;
			*)
				clear
				echo "Opção inválida."
				sleep 1
				;;
		esac
	done
}

select_default(){
	if [ "$DEFAULT_ON" -eq 1 ]; then
		echo "Valores definidos:"
		[ -z "$TYPE_ZIP" ] && echo "[C]   ->   null" || echo "[C]   ->   $ZIP_NAME"
		echo "[P]   ->   $FULL_PATH"
		[ -z "$FILES_TO_BKP" ] && echo "[A]   ->   null" || echo "[A]   ->   $FILES_TO_BKP"
		[ "$EXCLUDE_VALUE" == "OPTIONAL" ] && echo -e "[E]   ->   null" || echo -e "[E]   ->   $EXCLUDE_VALUE"
		[ "$SHOW_RSYNC" -eq 1 ] && echo -e "[R]   ->   enable"  || echo -e "[R]   ->   disable"
		[ "$PATH1" == "PATH1" ] && echo -e "[P1]  ->   null" || echo -e "[P1]   ->   $PATH1"
		[ "$PATH2" == "PATH2" ] && echo -e "[P2]  ->   null" || echo -e "[P2]   ->   $PATH2"
		echo
	fi
}

show_config(){
	[ "$TYPE_ZIP" == "" ] && SHOW_COMPRESS="COMPRESS" || SHOW_COMPRESS="$TYPE_ZIP"
	[[ "$FULL_PATH" == "$PWD"/backup/bkp.*.tar ]] && SHOW_PATH="PATH" || SHOW_PATH="$FULL_PATH"
	[ "$FILES_TO_BKP" == "" ] && SHOW_ARCHIVES="ARCHIVES" || SHOW_ARCHIVES="$FILES_TO_BKP"
	[ -z "$PATH1" ] && PATH1="PATH1"
	[ -z "$PATH2" ] && PATH2="PATH2"
	[ -z "$EXCLUDE_VALUE" ] && EXCLUDE_VALUE="OPTIONAL"
	[ "$OPTINAL_ON" -eq 1 ] && printf  	"		tar -c\e[1;35m[\e[0m$SHOW_COMPRESS\e[1;35m]\e[0mf \e[1;32m[\e[0m$SHOW_PATH\e[1;32m]\e[0m --exclude=\"\e[1;31m[\e[0m$EXCLUDE_VALUE\e[1;31m]\e[0m\" \e[1;32m[\e[0m$SHOW_ARCHIVES\e[1;32m]\e[0m \n" || printf 	"		tar -c\e[1;35m[\e[0m$SHOW_COMPRESS\e[1;35m]\e[0mf \e[1;32m[\e[0m$SHOW_PATH\e[1;32m]\e[0m \e[1;32m[\e[0m$SHOW_ARCHIVES\e[1;32m]\e[0m\n"

	[ "$SHOW_RSYNC" -eq 1 ] && printf "\n		rsync -av \e[1;32m[\e[0m$PATH1\e[1;32m]\e[0m \e[1;34m[\e[0m$PATH2\e[1;34m]\e[0m\n"
}

rsync_enable(){
		while true; do
			clear
			echo "Sincronização de diretórios."
			echo
			echo "[R]eset		->	Reseta a configuração e volta para o menu principal."
			echo "[F]inish	->	Finaliza a configuração e volta para o menu principal."
			echo "[D]efault	->	Define o diretório dos backups como input."
			echo
			echo -e "		rsync -av \e[1;34m[\e[0m$PATH1\e[1;34m]\e[0m \e[1;34m[\e[0m$PATH2\e[1;34m]\e[0m"
			echo
			echo "Configure os caminhos:"
			echo "[1]   ->   Define o diretório de input."
			echo "[2]   ->   Define o diretório de output."
			echo
			read -p ": " SELECT_PATH_RSYNC
			case "$SELECT_PATH_RSYNC" in
				1)
					read -p "PATH1: " PATH1
					;;
				2)
					read -p "PATH2: " PATH2
					;;
				D)
					PATH1="$PATH_DIR_BKP"
					;;
				F)
					SHOW_RSYNC=1
					break
					;;
				R)
					[ "$SHOW_RSYNC" -eq 0 ] && SHOW_RSYNC=1 || SHOW_RSYNC=0
					PATH1=""
					PATH2=""
					break
					;;
				*)
					clear
					echo "Opção inválida."
					sleep 1
					;;
			esac
		done
}

select_exclude(){
	while true; do
		clear
		echo "Valores para a opção --exclude." 
		echo
		echo "[R]eset		->	Reseta e volta para o menu principal."
		echo "[F]inish	->	Finaliza e volra para o menu principal."
		echo "[S]et		->	Define o valor da opção."
		echo
		echo "--exclude= $EXCLUDE_VALUE"
		echo
		read -p ": " SET_EXCLUDE
		case "$SET_EXCLUDE" in
			R)
				EXCLUDE_VALUE=""
				break
				;;
			F)
				break
				;;
			S)
				read -p "valor: " EXCLUDE_VALUE
				;;
			*)
				clear
				echo "Opção inválida."
				sleep 1
				;;
		esac
	done
}

menu_config(){
	while true; do
		clear
		echo "Script simples para Backups."
		echo
		echo -e "\e[1;34m[\e[0mR\e[1;34m]\e[0msync		->	Configura a Sincronização de diretórios."
		echo "[V]alues 	->	Mostra valores definidos."
		echo "[O]ptional	->	Mostra a opção extra."
		echo "[F]inish	->	Finaliza as configurações."
		echo -e "\e[1;31m[\e[0mQ\e[1;31m]\e[0muit		->	Sai do script."
		echo
		select_default
		echo
		show_config
		echo
		echo
		[ "$OPTINAL_ON" -eq 0 ] && echo "Comandos: [C]ompress [P]ath [A]rchives" || echo -e "Comandos: [C]ompress [P]ath [A]rchives \e[1;31m[\e[0mE\e[1;31m]\e[0mxclude"
		read -p ": " MAIN_CMD
		case "$MAIN_CMD" in
			C)
				select_compress	
				;;
			P)
				select_destiny
				;;
			A)
				select_archives
				;;
			R)
				rsync_enable
				;;
			O)
			#	select_optional
				[ "$OPTINAL_ON" -eq 0 ] && OPTINAL_ON=1 || OPTINAL_ON=0
				;;
			E)
				[ "$OPTINAL_ON" -eq 0 ] && clear && echo "Opção inválida."
				select_exclude
				;;
			V)
				[ "$DEFAULT_ON" -eq 0 ] && DEFAULT_ON=1 || DEFAULT_ON=0
				;;
			Q)
				clear
				echo "Saindo."
				exit 0
				;;
			F)
				[ ! -d $PATH_DIR_BKP ] && echo "O diretório $PATH_DIR_BKP não existe." && echo "Criando o diretório." && sleep 2 && mkdir $PATH_DIR_BKP
				[ "$EXCLUDE_VALUE" == "OPTIONAL" ] && EXCLUDE_VALUE="" || EXCLUDE_VALUE="--exclude=\"$EXCLUDE_VALUE\""
				zip_test
				exec_tar
				[ "$SHOW_RSYNC" -eq 1 ] && exec_rsync
				break
				;;
			*)
				clear
				echo "Opção inválida."
				sleep 1
				;;
		esac
	done
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
	clear
	echo "Iniciando a compactação."
	sleep 2
	echo 
	tar -c"$TYPE_ZIP"f "$FULL_PATH$ZIP_EXTENSION" $EXCLUDE_VALUE $FILES_TO_BKP 
	[ "$?" -eq 0 ] && printf "\nBackup feito com sucesso!"
	echo
}

exec_rsync(){
	echo "Inciando a sincronização de diretórios "
	sleep 2
	echo
	rsync -av "$PATH1" "$PATH2" 
	[ "$?" -eq 0 ] && sleep 2 && echo "Sincronização feita com sucesso!"
	echo
}

check_user
menu_config
