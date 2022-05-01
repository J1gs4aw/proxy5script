#!/bin/bash
# 
##########################################################################
#                                    change logs 
##########################################################################
# alteracoes na valida�a� do sistemas operacionais Debian ubuntu etc..
# altera��o do log 
# valida��o de o pacote foi instalado com sucesso var $PACOTE e versao instalada $VERSION_PROXYFIVE
# Criacao de funcoes para valida��o de sistema operacional e instala��o do proxychayns
#
# falta
# - fazer a valida��o dos outros s.o centos 6 e 7 
# - testar com outros systemas operacionais 
#colors
        Black='\033[0;30m'        # Black
        Red='\033[0;31m'          # Red
        Green='\033[0;32m'        # Green
        Yellow='\033[0;33m'       # Yellow
        Blue='\033[0;34m'         # Blue
        Purple='\033[0;35m'       # Purple
        Cyan='\033[0;36m'         # Cyan
        White='\033[0;37m'        # White
barra="####################################################################################"
echo $barra
echo -e  "                 $Green  AUTOMATIZADOR DE PROXYCHAYNS
$Blue
 ____  ____   _____  ____   _______ _____     _______ 
|  _ \|  _ \ / _ \ \/ /\ \ / /  ___|_ _\ \   / / ____|
| |_) | |_) | | | \  /  \ V /| |_   | | \ \ / /|  _|  
|  __/|  _ <| |_| /  \   | | |  _|  | |  \ V / | |___ 
|_|   |_| \_\\___/_/\_\  |_| |_|   |___|  \_/  |_____|
                                                       $White wwww.proxyfive.com.br
                                                        Data `date +%D`
                                                        vers�o 2.0
"
echo $barra

##VARIAVEIS GLOBAIS 
#so 
ID=`grep -e  ^ID /etc/os-release | sed 's/ID=//g' | grep -v ID_LIKE`
ID_LIKE=`grep -e  ID_LIKE /etc/os-release | tr -d "A-Z_="'"' | awk '{ print $1'}`
VERSION=`grep -e  ^PRETTY_NAME /etc/os-release |  sed 's/PRETTY_NAME="//g'`
VERSION_SO=`cat /etc/os-release | sed 's/ID=//g' | grep "VERSION" | tr -d "A-Z_="'"' | awk '{ print $1}' | uniq`

precheck(){ #verificar se o s.o tem os requisitos minimo para seguir
        ID=`grep -e  ^grep -e  ^ID /etc/os-release | sed 's/ID=//g' | grep -v ID_LIKE | tr -d '"'`
        ID_LIKE=`grep -e  ID_LIKE /etc/os-release | tr -d "A-Z_="'"' | awk '{ print $1'}`
        VERSION=`grep -e  ^PRETTY_NAME /etc/os-release |  sed 's/PRETTY_NAME="//g'`
        VERSION_SO=`cat /etc/os-release | sed 's/ID=//g' | grep "VERSION" | tr -d "A-Z_="'"' | awk '{ print $1}' | uniq`
        VERSION_ID=`cat /etc/os-release | grep ^VERSION_ID= | tr -d A-Z,'_=''"'` #rocky linux

        if [ $ID = "debian" ] || [ $ID_LIKE = "debian" ] 
        then 
                echo "por favor aguarde um momento"
        	apt update && apt install dialog proxychains curl wget -y >> /var/log/proxyfive_install.log 
        	#apt install proxychains curl wget -y 1> /tmp/log_apt.txt  2> /tmp/log_apt_erro.txt

                if [ -f  /usr/bin/dialog ]
        	then
                        echo "Sistema compativel" 
        	else 
        	        echo "Desculpe ocorreu um erro, verifique no arquivo de log /var/log/proxyfive_install.log"
        	fi
        fi
        ##########################################################
        #                      CENTOS OU REDHAT 8.5
        ##########################################################
        if [ $ID = "rhel" ] && [ $VERSION_SO = "8.5" ];
        then  
        	echo "por favor aguarde um momento"
        	yum install curl dialog wget proxychains-ng -y  >> /var/log/proxyfive_install.log
        	check_dialog
        ##########################################################
        #                      CENTOS OU REDHAT 7
        ##########################################################
        elif [ $ID_LIKE = "rhel" ] && [ $VERSION_SO = "7" ];
        then 
                echo "por favor aguarde um momento"
        	yum install curl dialog wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/p/proxychains-ng-4.16-1.el7.x86_64.rpm -y 
        	check_dialog
        ##########################################################
        #                      ROCKY LINUX 
        ##########################################################
        elif [ $ID_LIKE = "rhel" ] && [ $VERSION_ID = "8.5" ];
        then 
                yum install curl dialog wget proxychains-ng -y  >> /var/log/proxyfive_install.log
                check_dialog
        else
        	echo "sistema não não encontrado, por favor verifique a documentação official"
        	echo "www.proxyfive.com.br"
        fi 
}

## Funcoes 
##validar se o proxychayns foi instalado (Debian)

check_dialog(){
        if [ -f  /usr/bin/dialog ]
	then
                echo "Sistema compativel" 
	else 
		echo "Desculpe ocorreu um erro"
        fi	
}

validador_debian(){
        echo "Sistema operacional compativel"
        echo "Instalando o proxychains"
        apt install proxychains curl wget -y 1> /tmp/log_apt.txt  2> /tmp/log_apt_erro.txt
	PACOTE=`dpkg -l proxychains | grep -i "proxychains" | awk '{print $2}'`
	VERSION_PROXYCHAYNS=`dpkg -l proxychains | grep -i "proxychains" | awk '{print $3}'`
	
	if [[ $PACOTE = "proxychains" ]]
	then 
		echo "Pacote instalado com sucesso $PACOTE vers�o $VERSION_PROXYCHAYNS"
	else 
		echo "Pacote n�o instalado por favor, verifique o arquivo de log /tmp/log_apt.txt"]
	fi
}

instalador_debian(){
        precheck #verifica se o s.o tem o dialog instalado
	PACOTE=`dpkg -l proxychains | grep -i "proxychains" | awk '{print $2}'`
	VERSION_PROXYCHAYNS=`dpkg -l proxychains | grep -i "proxychains" | awk '{print $3}'`
	
	if [[ $PACOTE = "proxychains" ]]
	then 
	        dialog                                          \
   		--title 'Parabens'                              \
   		--msgbox 'Instalacao finalizada com sucesso.'   \
   		6 40

	else 
		tail /var/log/proxyfive_install.log > out &
		dialog                                         \
   		--title 'Ocorre um erro'  \
		--tailbox out                               \
   		0 0
	fi
}

instalador_redhat(){
        precheck #verifica se o s.o tem o dialog instalado
	PACOTE_NAME=`rpm -qa --qf '%{NAME} %{VERSION}\n'   | grep proxychains | awk '{print $1}'`
	PACOTE_VERSION=`rpm -qa --qf '%{NAME} %{VERSION}\n'   | grep proxychains | awk '{print $2}'`
	
	if [[ $PACOTE_NAME = "proxychains-ng" ]]
	then 
	        dialog                                         \
   		--title 'Parabens'                             \
   		--msgbox 'Instalacao finalizada com sucesso.'  \
   		6 40

	else 
		tail  /var/log/proxyfive_install.log > out &
		dialog                                         \
   		--title 'Ocorreu um erro'  \
		--tailbox out                               \
   		0 0
	fi
}

##validar se o proxychayns foi instalado (Redhat)

validador_redhat(){
if [ $ID_LIKE = "rhel" ] && [ $VERSION_SO = "8" ];
then 
	echo -e "$Green Sistema operacional compativel"
	echo "iniciando a instala��o dos pacotes necess�rios"
	yum install curl wget -y
	cd /tmp/ && wget https://pkgs.dyn.su/el8/base/x86_64/proxychains-ng-4.13-4.el8.x86_64.rpm && yum install -y proxychains-ng*.rpm 1> /tmp/log_apt.txt  2> /tmp/log_yum_erro.txt

#validando de foi instalado 
	PACOTE=`rpm -qi proxychains-ng | head -n1 | awk '{print $3'}`
	VERSION_PROXYCHAYNS=`rpm -qi proxychains-ng  | grep "Version" | awk '{ print $3 }'`

#Rhel 7
#elif [ $ID_LIKE = "rhel" ] && [ $VERSION_SO = "7" 
#	echo -e "$Green Sistema operacional compativel"
#	echo "iniciando a instala��o dos pacotes necess�rios"
#	yum install curl wget -y
#	cd /tmp/ && wget https://pkgs.dyn.su/el8/base/x86_64/proxychains-ng-4.13-4.el8.x86_64.rpm && yum install -y proxychains-ng*.rpm 1> /tmp/log_apt.txt  2> /tmp/log_yum_erro.txt
	
#if [[ $PACOTE = "proxychains-ng" ]]
#then
	echo "Pacote instalado com sucesso $PACOTE vers�o:$VERSION_PROXYCHAYNS"
	 
else 
	echo "Pacote n�o instalado por favor, verifique o arquivo de log /tmp/log_yum_erro.txt"
fi
}

if [[ $EUID != 0 ]]
then
        echo "Por favor, execute o script como root"
        exit    

elif [[ $EUID -eq 0 ]]
then
        if [ $ID = "debian" ] || [ $ID_LIKE = "debian" ]
        #DEBIAN
        then
	        menu(){
                escolha=$( dialog --stdout                                      \
                        --title 'Automatizador de Proxychayns'                  \
                        --menu 'Escolha uma das opcoes:'                        \
                        0 0 0                                                   \
                        Lista       'Lista aleatoria de proxys'                 \
                        Configurar  'Definir opcoes dos proxys utilizados'      \
                        Instalar    'Instalar proxychains'                      \
                        Sair  'Sair')
                }

                menu

                proxychains_list(){

                        Nproxys=$( dialog --stdout                                              \
                        --title 'Numero de servidores proxys'                                   \
                        --inputbox 'digite o numero de servidore proxys que deseja utilizar:'   \
                        0 0                                                                     \
                        )
                                
                        rm -f /tmp/proxychains.txt
                        rm -f /tmp/proxychainss.txt
                        wget -O /tmp/proxychainss.txt https://api.proxyscrape.com/v2/?request=getproxies\&protocol=socks5\&timeout=10000\&country=all
                        sed 's/^/socks5 /'  /tmp/proxychainss.txt | tr ':' ' ' >> /tmp/proxychains.txt
                        head -n $Nproxys /tmp/proxychains.txt >> /etc/proxychains4.conf
                        Nproxys=$(tail -n $Nproxys /tmp/proxychains.txt)

                        dialog --stdout                 \
                        --title 'Proxys adicionados'    \
                        --infobox "$Nproxys"            \
                        0 0                             \

                        sleep 3

                        rm -f /tmp/proxychains.txt
                        rm -f /tmp/proxychainss.txt
                                
                        exit
                }

                proxychains_config(){
                        while [ "$tipoProxy" != "1" ] && [ "$tipoProxy" != "2" ] && [ "$tipoProxy" != "3" ]
                        do
                                tipoProxy=$( dialog --stdout                                                            \
                                --title 'Tipo de servidor proxy'                                                        \
                                --radiolist 'selecione a opcao desejada para o protocolo utilizado na comunicacao'      \
                                0 0 0                                                                                   \
                                1 'HTTP'      off                                                                       \
                                2 'SOCKS4'    off                                                                       \
                                3 'SOCKS5'    on                                                      
                                )
                                        
                                if [ $tipoProxy -eq 1 ]
                                then
                                        tipoProxy="http"
                                        break

                                elif [ $tipoProxy -eq 2 ]
                                then
                                        tipoProxy="socks4"
                                        break

                                elif [ $tipoProxy -eq 3 ]
                                then
                                        tipoProxy="socks5"
                                        break
                                fi
                        done

                        if [ "$tipoProxy" == "http" ]
                        then
                                while [ "$anomProxy" != "1" ] && [ "$anomProxy" != "2" ] && [ "$anomProxy" != "3" ] && [ "$anomProxy" != "4" ]
                                do 
                                
                                anomProxy=$( dialog --stdout                                                            \
                                --title 'Nivel da anonimidade'                                                          \
                                --radiolist 'selecione a opcao desejada para o nivel de anonimidade da comunicacao'     \
                                0 0 0                                                                                   \
                                1 'TODAS'        on                                                                     \
                                2 'ELITE'        off                                                                    \
                                3 'ANONIMO'      off                                                                    \
                                4 'TRANSPARENTE' off    
                                )

                                if [ $anomProxy -eq 1 ]
                                then
                                anomProxy="all"
                                break

                                elif [ $anomProxy -eq 2 ]
                                then
                                anomProxy="elite"
                                break

                                elif [ $anomProxy -eq 3 ]
                                then
                                anomProxy="anonymous"
                                break

                                elif [ $anomProxy -eq 4 ]
                                then
                                anomProxy="transparent"
                                break

                                fi
                                done
                        fi

                                if [ "$tipoProxy" == "http" ]
                                then
                                        while [ "$SSLproxy" != "1" ] && [ "$SSLproxy" != "2" ] && [ "$SSLproxy" != "3" ]
                                        do
                                        
                                        SSLproxy=$( dialog --stdout                                                     \
                                        --title 'Utilizacao de SSL'                                                     \
                                        --radiolist 'selecione a opcao desejada para utilizacao de SSL na comunicacao:' \
                                        0 0 0                                                                           \
                                        1 'TUDO'    on                                                                  \
                                        2 'SIM'     off                                                                 \
                                        3 'NAO'     off                                            
                                        )
                                        
                                        if [ $SSLproxy -eq 1 ]
                                        then
                                        SSLproxy="all"
                                        break

                                        elif [ $SSLproxy -eq 2 ]
                                        then
                                        SSLproxy="yes"
                                        break

                                        elif [ $SSLproxy -eq 3 ]
                                        then
                                        SSLproxy="no"
                                        break

                                        fi
                                        done
                                fi

                                while [ "$pingProxy" == "" ]
                                do

                                pingProxy=$( dialog --stdout                                                                            \
                                --title 'Limite de timeout'                                                                             \
                                --inputbox 'Timeout em milissegundos, quanto menor o numero, menos proxys poderao estar disponiveis.\n(50ms - 10000ms apenas o numero, sem espacos ou caracteres especiais): ' \
                                0 0                                                                                                     \
                                )

                                if [ "$pingProxy" -gt "49" ] && [ "$pingProxy" -lt "10000" ]
                                then

                                        dialog --stdout                 \
                                        --title 'Atencao!'    \
                                        --yesno "\n tipo do proxy: $tipoProxy \n utiliza ssl: $SSLproxy \n nivel de anonimidade: $anomProxy \n limite de ping: $pingProxy \n \n confirma as informacoes acima? \n"            \
                                        0 0                             \
                                        
                                        confirm=$?

                                        if [ "$confirm" == 0 ]
                                        then
                                                proxychains_list

                                        elif [ "$confirm" == 1 ]
                                        then
                                                dialog --stdout         \
                                                --title 'Atencao!'      \
                                                --infobox 'Saindo...'   \
                                                0 0

                                                sleep 1
                                                exit
                                        fi

                                fi
                                pingProxy=""

                                done

                        dialog --stdout         \
                        --title 'Atencao!'      \
                        --infobox 'Saindo...'   \
                        0 0
                        sleep 1                                
                                
                        exit
                
                }

        if [ "$escolha" = 'Lista' ]
        then  
                echo "ESCOLHEU LISTA AUTOMATIZADOR"
                proxychains_list
        fi
        
        if [ "$escolha" = 'Configurar' ]
        then  
                echo "ESCOLHEU CONFIGURAR OS PROXYS"
                proxychains_config
        fi
        
        if [ "$escolha" = 'Instalar' ]
        then
                if [ $ID = "debian" ] || [ $ID_LIKE = "debian" ]; 
                then 
                        instalador_debian
                elif [ $ID = "rhel" ] && [ $VERSION_SO = "8.5" ];
                then
                        instalador_redhat
                elif [ $ID = "rhel" ] && [ $VERSION_SO = "8.5" ];
                then 
                        instalador_redhat

                elif [ $ID_LIKE = "rhel" ] && [ $VERSION_SO = "7" ];
                then 
                        instalador_redhat
                else 
                        echo "Desculpe ocorreu um erro"
                fi
        fi

        if [ "$escolha" = 'Sair' ]
        then
                dialog --stdout         \
                --title 'Atencao!'      \
                --infobox 'Saindo...'   \
                0 0
                sleep 1                 
                
                exit
        fi

        #REDHAT
        elif [ $ID_LIKE = "rhel" ]
        then
				validador_redhat  #Esta funcao validaram se o s.o � compativel				
                echo "iniciando a configura��o do proxychays"
				PS3="escolha uma opcao: "
                options=("Adicionar lista aleatoria de servidores proxy 1" "Definir opcoes de proxys 2" "Sair 3")
                select opt in "${options[@]}"
                do
                        case $opt in
                                "Adicionar lista aleatoria de servidores proxy 1")
                                echo "digite o numero de servidores proxys que deseja (SOCKS5 por padrao): "
                                read Nproxys
                                echo $Nproxys
                                rm -f /tmp/proxychainss.txt
                                wget -O /tmp/proxychainss.txt https://api.proxyscrape.com/v2/?request=getproxies\&protocol=socks5\&timeout=10000\&country=all
                                sed 's/^/socks5 /'  /tmp/proxychainss.txt | tr ':' ' ' >> /tmp/proxychains.txt
                                head -n $Nproxys /tmp/proxychains.txt >> /etc/proxychains4.conf
                                rm -f /tmp/proxychainss.txt
                                rm -f /tmp/proxychains.txt
                                echo "Servidores adicionados: "
                                tail -n $Nproxys /etc/proxychains4.conf
                                ;;

                                "Definir opcoes de proxy 2")
                                echo "deu bom 2"
                                ;;

                                "Sair 3")
                                echo "saiu"
                                break
                                ;;

                                *) echo -e "\e[1;33m OP��O INCORRETA $REPLY\e[0m"
                                ;;
                        esac
                done        

else
        echo "Sistema operacional incompativel"
        exit
fi
fi
