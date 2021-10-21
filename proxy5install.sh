#!/bin/bash
#colors
        Black='\033[0;30m'        # Black
        Red='\033[0;31m'          # Red
        Green='\033[0;32m'        # Green
        Yellow='\033[0;33m'       # Yellow
        Blue='\033[0;34m'         # Blue
        Purple='\033[0;35m'       # Purple
        Cyan='\033[0;36m'         # Cyan
        White='\033[0;37m'        # White
barra="############################################################################"
echo $barra
echo -e  "                 $Green  automatizador de proxychains
$Yellow
                                             __   _
      _ __    _ __    ___   __  __  _   _   / _| (_) __   __   ___
     | '_ \  | '__|  / _ \  \ \/ / | | | | | |_  | | \ \ / /  / _ \
     | |_) | | |    | (_) |  >  <  | |_| | |  _| | |  \ V /  |  __/
     | .__/  |_|     \___/  /_/\_\  \__, | |_|   |_|   \_/    \___|
     |_|                            |___/
                                                       $White wwww.proxyfive.com.br
                                                        Usuario $USER
                                                        Data `date +%D`
                                                        versão 1.0
"

if [[ $EUID != 0 ]]
then
        echo "Por favor, execute o script como root"
        exit    

elif [[ $EUID -eq 0 ]]
then
        #verificando a versao do so
        RELEASE=`cat  /etc/*release`
        ID=`grep -e  ^ID /etc/os-release | sed 's/ID=//g' | grep -v ID_LIKE`
        ID_LIKE=`grep -e  ID_LIKE /etc/os-release | tr -d "A-Z_="'"' | awk '{ print $1'}`
        VERSION=`grep -e  ^PRETTY_NAME /etc/os-release |  sed 's/PRETTY_NAME="//g'`

        if [ $ID_LIKE = "debian" ]
        #DEBIAN
        then
                echo "Sistema operacional compativel"
                echo "Seu sistema operacional é $ID_LIKE versao $VERSION"
                echo "Instalando o proxychains"
                apt install proxychains -y 1> /tmp/log_apt.txt  2> /tmp/log_apt_erro.txt
                #dpkg -l  | grep proxychains 

                PS3="Escolha uma opcao: "
                options=("Adicionar lista aleatoria de servidores proxy 1" "Definir opcoes de proxys 2" "Sair 3")
                select opt in "${options[@]}"
                do
                        case $opt in
                                "Adicionar lista aleatoria de servidores proxy 1")
                                echo -n "digite o numero de servidores proxys que deseja (SOCKS5 por padrao): "
                                read Nproxys
                                echo $Nproxys
                                rm -f /tmp/proxychainss.txt
                                wget -O /tmp/proxychainss.txt https://api.proxyscrape.com/v2/?request=getproxies\&protocol=socks5\&timeout=10000\&country=all
                                sed 's/^/socket4 /'  /tmp/proxychainss.txt | tr ':' ' ' >> /tmp/proxychains.txt
                                #echo "proxys editados: " $variavel
                                head -n $Nproxys /tmp/proxychains.txt >> /etc/proxychains4.conf
                                rm -f /tmp/proxychainss.txt
                                rm -f /tmp/proxychains.txt
                                echo "Servidores adicionados: "
                                tail -n $Nproxys /etc/proxychains4.conf
                                ;;

                                "Definir opcoes de proxy 2")
                                echo -n "escolher o tipo de servidor proxy:"
                                echo -n "| HTTP | SOCKS4 | SOCKS5 |"
                                read tipoProxy

                                echo -n "escolher o nivel de anonimidade:"
                                echo -n "| todas | elite | anonimo | transparente |"
                                read anomProxy
                                
                                echo -n "SSL:"
                                echo -n "| tudo | sim | nao |"
                                read SSLproxy

                                echo -n "Timeout, em milissegundos: "
                                echo -n "50ms - 10000ms (apenas o numero)"
                                read pingProxy

                                if [tipoProxy -eq "HTTP"]
                                then
                                echo "DENTRO DO IF"
                                read

                                fi

                                ;;

                                "Sair 3")
                                echo "saiu"
                                break
                                ;;

                                *) echo -e "\e[1;33m OPÇÃO INCORRETA $REPLY\e[0m"
                                ;;
                        esac
                done

        #REDHAT
        elif [ $ID = "rhel" ]
        then
                echo "sistema operacional compativel"
                echo "seu sistema operacional é  $ID_LIKE versao $VERSION"
                echo "iniciando a configuração do proxychays"
                PS3="escolha uma opcao: "
                options=("Adicionar lista aleatoria de servidores proxy 1" "Definir opcoes de proxys 2" "Sair 3")
                select opt in "${options[@]}"
                do
                        case $opt in
                                "Adicionar lista aleatoria de servidores proxy 1")
                                echo -n "digite o numero de servidores proxys que deseja (SOCKS5 por padrao): "
                                read Nproxys
                                echo $Nproxys
                                rm -f /tmp/proxychainss.txt
                                wget -O /tmp/proxychainss.txt https://api.proxyscrape.com/v2/?request=getproxies\&protocol=socks5\&timeout=10000\&country=all
                                sed 's/^/socket4 /'  /tmp/proxychainss.txt | tr ':' ' ' >> /tmp/proxychains.txt
                                #echo "proxys editados: " $variavel
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
