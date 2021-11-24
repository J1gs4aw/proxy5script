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

                PS3="Escolha uma opcao (opcao 1 recomendada por apresentar maior seguranca e facilidade): "
                options=("Adicionar lista aleatoria de servidores proxy 1" "Definir opcoes de proxys 2" "Sair 3")
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