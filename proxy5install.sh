#!/bin/bash
# 
##########################################################################
#                                    change logs 
##########################################################################
# alteracoes na validação do sistemas operacionais Debian ubuntu etc..
# alteração do log 
# validação de o pacote foi instalado com sucesso var $PACOTE e versao instalada $VERSION_PROXYFIVE
# Criacao de funcoes para validação de sistema operacional e instalação do proxychayns
#
# falta
# - fazer a validação dos outros s.o centos 6 e 7 
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
                                                        versão 2.0
"
echo $barra

##VARIAVEIS GLOBAIS 
#so 
ID=`grep -e  ^ID /etc/os-release | sed 's/ID=//g' | grep -v ID_LIKE`
ID_LIKE=`grep -e  ID_LIKE /etc/os-release | tr -d "A-Z_="'"' | awk '{ print $1'}`
VERSION=`grep -e  ^PRETTY_NAME /etc/os-release |  sed 's/PRETTY_NAME="//g'`
VERSION_SO=`cat /etc/os-release | sed 's/ID=//g' | grep "VERSION" | tr -d "A-Z_="'"' | awk '{ print $1}' | uniq`

## Funcoes 
##validar se o proxychayns foi instalado (Debian)

validador_debian() 
	{
	echo "Sistema operacional compativel"
    echo "Instalando o proxychains"
    apt install proxychains curl wget -y 1> /tmp/log_apt.txt  2> /tmp/log_apt_erro.txt
	PACOTE=`dpkg -l proxychains | grep -i "proxychains" | awk '{print $2}'`
	VERSION_PROXYCHAYNS=`dpkg -l proxychains | grep -i "proxychains" | awk '{print $3}'`
	
	if [[ $PACOTE = "proxychains" ]]
	then 
		echo "Pacote instalado com sucesso $PACOTE versão $VERSION_PROXYCHAYNS"
	else 
		echo "Pacote não instalado por favor, verifique o arquivo de log /tmp/log_apt.txt"]
	fi
}
##validar se o proxychayns foi instalado (Redhat)

validador_redhat() 
{		
if [ $ID_LIKE = "rhel" ] && [ $VERSION_SO = "8" ];
then 
	echo -e "$Green Sistema operacional compativel"
	echo "iniciando a instalação dos pacotes necessários"
	yum install curl wget -y
	cd /tmp/ && wget https://pkgs.dyn.su/el8/base/x86_64/proxychains-ng-4.13-4.el8.x86_64.rpm && yum install -y proxychains-ng*.rpm 1> /tmp/log_apt.txt  2> /tmp/log_yum_erro.txt

#validando de foi instalado 
	PACOTE=`rpm -qi proxychains-ng | head -n1 | awk '{print $3'}`
	VERSION_PROXYCHAYNS=`rpm -qi proxychains-ng  | grep "Version" | awk '{ print $3 }'`
	
#if [[ $PACOTE = "proxychains-ng" ]]
#then
	echo "Pacote instalado com sucesso $PACOTE versão:$VERSION_PROXYCHAYNS"
	 
else 
	echo "Pacote não instalado por favor, verifique o arquivo de log /tmp/log_yum_erro.txt"
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
			   validador_debian #Esta funcao validaram se o s.o é compativel
               
			   PS3="Escolha uma opcao (opcao 1 recomendada por apresentar maior seguranca e facilidade): "
                options=(
						"Adicionar lista aleatoria de servidores proxy 1" 
						"Definir opcoes de proxys 2" 
						"Sair 3"
						)
				
				
                select opt in "${options[@]}"
                do
                        case $opt in
                                "Adicionar lista aleatoria de servidores proxy 1")
                                echo "digite o numero de servidores proxys que deseja, apenas o numero, sem espacos ou caracteres especiais (SOCKS5 por padrao): "
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
                                exit
                                ;;

                                "Definir opcoes de proxys 2")
                                
                                while [ "$tipoProxy" != "1" ] && [ "$tipoProxy" != "2" ] && [ "$tipoProxy" != "3" ]
                                do 
                                echo "escolher o tipo de servidor proxy (utilizar o numero da opcao desejada):"
                                echo "HTTP      (1)"
                                echo "SOCKS4    (2)" 
                                echo "SOCKS5    (3)"
                                read tipoProxy

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

                                else
                                echo "favor utilizar um dos valores "

                                fi
                                done
                                
                                if [ "$tipoProxy" == "http" ]
                                then
                                        while [ "$anomProxy" != "1" ] && [ "$anomProxy" != "2" ] && [ "$anomProxy" != "3" ] && [ "$anomProxy" != "4" ]
                                        do 
                                        echo "escolher o nivel de anonimidade(utilizar o numero da opcao desejada):"
                                        echo "TODAS             (1)"
                                        echo "ELITE             (2)"
                                        echo "ANONIMO           (3)"
                                        echo "TRANSPARENTE      (4)"
                                        read anomProxy

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

                                        else
                                        echo "favor utilizar um dos valores "

                                        fi
                                        done
                                fi

                                if [ "$tipoProxy" == "http" ]
                                then
                                        while [ "$SSLproxy" != "1" ] && [ "$SSLproxy" != "2" ] && [ "$SSLproxy" != "3" ]
                                        do
                                        echo " (utilizar o numero da opcao desejada):"
                                        echo "TUDO     (1)"
                                        echo "SIM      (2)"
                                        echo "NAO      (3)"
                                        read SSLproxy
                                        
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

                                        else
                                        echo "favor utilizar um dos valores "

                                        fi
                                        done
                                fi

                                while [ "$pingProxy" == "" ]
                                do
                                echo "Timeout, em milissegundos (quanto menor o numero, menos proxys poderao estar disponiveis): "
                                echo "50ms - 10000ms (apenas o numero, sem espacos ou caracteres especiais)"
                                read pingProxy

                                if [ "$pingProxy" -gt "50" ] && [ "$pingProxy" -lt "10000" ]
                                then
                                break
                                
                                fi
                                pingProxy=""

                                done

                                echo "digite o numero de servidores proxys que deseja (apenas o numero, sem espacos ou caracteres especiais): "
                                read Nproxys
                                echo $Nproxys

                                rm -f /tmp/proxychainss.txt
                                wget -O /tmp/proxychainss.txt https://api.proxyscrape.com/v2/?request=getproxies&protocol=$tipoProxy&timeout=$pingProxy&country=all&ssl=$SSLproxy&anonymity=$anomProxy
                                sed 's/^/socks5 /'  /tmp/proxychainss.txt | tr ':' ' ' >> /tmp/proxychains.txt
                                head -n $Nproxys /tmp/proxychains.txt >> /etc/proxychains4.conf
                                rm -f /tmp/proxychainss.txt
                                rm -f /tmp/proxychains.txt
                                echo "Servidores adicionados: "
                                tail -n $Nproxys /etc/proxychains4.conf                            
                                ;;

                                "Sair 3")
                                echo "saindo..."
                                break
                                ;;

                                *) echo -e "\e[1;33m OPÇÃO INCORRETA $REPLY\e[0m"
                                ;;
                        esac
                done

        #REDHAT
        elif [ $ID_LIKE = "rhel" ]
        then
				validador_redhat  #Esta funcao validaram se o s.o é compativel				
                echo "iniciando a configuração do proxychays"
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

                                *) echo -e "\e[1;33m OPÇÃO INCORRETA $REPLY\e[0m"
                                ;;
                        esac
                done        

else
        echo "Sistema operacional incompativel"
        exit
fi
fi
