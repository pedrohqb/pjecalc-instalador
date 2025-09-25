#!/bin/bash
#
# Autor: Fernando Souza - https://www.youtube.com/@fernandosuporte/
# Modificado por Pedro Henrique Quitete Barreto - pedrohqb@gmail.com
# Homepage: https://github.com/pedrohqb/pjecalc-instalador
# Licença:  MIT


# Logs de atualização

log="/tmp/pjecalc-update.log"

# URL da página de instalação

URL="https://www.trt8.jus.br/pjecalc-cidadao/instalando-o-pje-calc-cidadao"

logo="/usr/share/pixmaps/icone_calc.ico"

# Auto-atualização do PJeCalc Cidadão

clear


# ----------------------------------------------------------------------------------------


export DBUS_SESSION_BUS_ADDRESS=$(echo $DBUS_SESSION_BUS_ADDRESS)

export DISPLAY=:0.0


# ----------------------------------------------------------------------------------------


# Para verificar se os programas estão instalados

which yad           1> /dev/null 2> /dev/null || { echo "Programa Yad não esta instalado."      ; exit ; }

verificar_programa() {

    if ! which "$1" &> /dev/null; then

        echo  "O programa $1 não está instalado." >> "$log"

        yad --center \
            --title="Dependência ausente" \
            --window-icon="$logo" --image="$logo" \
            --text="O programa <b>$1</b> não está instalado.\n\nInstale-o antes de continuar." \
            --buttons-layout="center" \
            --button="OK" \
            --width="400" 2> /dev/null

        exit 1
    fi

}

# Verificações

verificar_programa notify-send
verificar_programa grep
verificar_programa curl
verificar_programa 7z
verificar_programa cut
verificar_programa java
verificar_programa wget
verificar_programa cp
verificar_programa ping
verificar_programa pgrep
verificar_programa sort
verificar_programa xdg-open
verificar_programa firefox


# ----------------------------------------------------------------------------------------


echo "
Testando conexão com à internet...
"

if ! ping -c 1 www.google.com.br -q &> /dev/null; then

    echo  "Sistema não tem conexão com à internet." >> "$log"

    echo -e "\033[1;31m[ERRO] - Seu sistema não tem conexão com à internet. Verifique os cabos e o modem.\n \033[0m"
    
    sleep 10
    
    yad \
    --center \
    --window-icon="$logo" \
    --image=dialog-error \
    --title "Aviso" \
    --fontname "mono 10"  \
    --text="\nSeu sistema não tem conexão com à internet. Verifique os cabos e o modem.\n" \
    --buttons-layout="center" \
    --button="OK"  \
    --width="600" --height="100"  \
    2> /dev/null
    
    exit 1
    
    else
    
    echo -e "\033[1;32m[VERIFICADO] - Conexão com à internet funcionando normalmente. \033[0m"
    
    sleep 2
    
fi


# ----------------------------------------------------------------------------------------


# Baixar o conteúdo da página e procurar o link do instalador

if [[ $(uname -m) == x86_64 ]]; then

# Instalador PJe-Calc Cidadão 64bits

# echo -e "\nPJe-Calc Cidadão 64bits \n"

arch="x64"

VERSAO=$(curl -s "$URL" 2> /dev/null | grep -oP 'pjecalc-[0-9]+\.[0-9]+\.[0-9]+(?=-instalador-x64\.exe)' | head -n 1)

else

# Instalador PJe-Calc Cidadão 32bits

# echo -e "\nPJe-Calc Cidadão 32bits \n"

arch="x32"

VERSAO=$(curl -s "$URL" 2> /dev/null | grep -oP 'pjecalc-[0-9]+\.[0-9]+\.[0-9]+(?=-instalador-x32\.exe)' | head -n 1)

fi

# Para verificar se a variavel é nula

if [ -z "$VERSAO" ];then

    echo -e "\033[1;31mVersão do PJeCalc Cidadão não identificada no site...\n \033[0m"

    exit

fi

# Filtrar

VERSAO=$(echo ""$VERSAO | cut -d"-" -f2)

# Exibir a versão do programa

VERSAO_SITE="$VERSAO"


# ----------------------------------------------------------------------------------------


# VERSAO INSTALADA

versao_instalada(){

# Detectar automaticamente a versão do PJeCalc instalada.

# Caminho do pjecalc.jar (ajuste conforme necessário)

JAR_PATH="$HOME/PJeCalc/bin/pjecalc.jar"

# Verifica se o arquivo existe

if [ ! -f "$JAR_PATH" ]; then

    echo -e "\033[1;31m\n[ERRO] - ❌ Arquivo $JAR_PATH não encontrado. \n\033[0m"

    exit 1
fi

# Tenta extrair a versão do MANIFEST.MF

VERSAO_ATUAL=$(unzip -p "$JAR_PATH" META-INF/MANIFEST.MF 2>/dev/null | grep -iE 'Implementation-Version|version' | head -n1 | awk -F': ' '{print $2}' | tr -d '\r')

# Caso não encontre, define mensagem padrão

if [ -z "$VERSAO_ATUAL" ]; then

    echo -e "\033[1;31m[ERRO] - ❌ Não foi possível detectar a versão do PJeCalc Cidadão no $JAR_PATH \033[0m"

    exit 1
fi

# Exibe a versão

echo "Versão instalada do PJeCalc Cidadão: $VERSAO_ATUAL"

}

# Verificar se tem o arquivo $HOME/PjeCalc/versao_instalada.txt

if [ -e "$HOME/PjeCalc/versao_instalada.txt" ]; then

VERSAO_ATUAL=$(cat $HOME/PjeCalc/versao_instalada.txt)

# Caso não encontre, define mensagem padrão

if [ -z "$VERSAO_ATUAL" ]; then

    echo -e "\033[1;31m[ERRO] - ❌ Não foi possível detectar a versão do PJeCalc Cidadão. \033[0m"

    exit 1
fi

# Exibe a versão

echo -e "\nVersão instalada do PJeCalc Cidadão: $VERSAO_ATUAL"

fi


# ----------------------------------------------------------------------------------------


# Se a versão instalada for maior que a versão do site não mostra o aviso.

# Se a versão instalada for menor do que o site mostra o aviso.

MENOR_VERSAO=$(printf '%s\n' "$VERSAO_ATUAL" "$VERSAO_SITE" | sort -V | head -n1)

# Lógica de verificação

if [ "$MENOR_VERSAO" != "$VERSAO_SITE" ]; then

        echo -e "\n🔔 Sua versão do PJeCalc Cidadão está desatualizada.\n"

erro_cron(){


# ----------------------------------------------------------------------------------------


    if yad --center --window-icon=dialog-warning --image="$logo" --title="Atualização disponível" --text="Nova versão do PJeCalc Cidadão disponível.\n\nVersão instalada: $VERSAO_ATUAL\nVersão disponível: $VERSAO_SITE\n\nDeseja atualizar?" --buttons-layout="center" --button=Não:1 --button=Sim:0 --width="400"  2> /dev/null ; then


# ----------------------------------------------------------------------------------------


echo "Processo de atualização..."

# Verificar se tem o arquivo /usr/local/bin/pjecalc-instalar-remover.sh

if [ -e "/usr/local/bin/pjecalc-instalar-remover.sh" ]; then

        echo -e "\nAtualizando para versão $VERSAO_SITE..."

/usr/local/bin/pjecalc-instalar-remover.sh

else

    echo -e "\033[1;31m[ERRO] - ❌ Desculpe, não foi possível encontrar o atualizador do PJeCalc Cidadão.\n\nVerifique a instalação... \033[0m"

notify-send  \
-i "$logo" \
-t 200000 \
"Atualização do PJeCalc Cidadão..." "\nDesculpe, não foi possível encontrar o atualizador do PJeCalc Cidadão.\n\nVerifique a instalação..."

exit

fi


# ----------------------------------------------------------------------------------------


else

notify-send  \
-i "$logo" \
-t 200000 \
"Atualização disponível do PJeCalc Cidadão..." "🔔 Sua versão do PJeCalc Cidadão está desatualizada."

        echo "
Versão instalada:  $VERSAO_ATUAL 
Versão disponível: $VERSAO_SITE
"
  
    sleep 2

    # No cron cai sempre aqui e não abre o yad.

    echo -e "\033[1;31m[ERRO] - ❌ Usuário optou por não atualizar. \033[0m"

fi


# ----------------------------------------------------------------------------------------


}

# erro_cron

echo "
Versão instalada:  $VERSAO_ATUAL 
Versão disponível: $VERSAO_SITE
"

notify-send  \
-i "$logo" \
-t 200000 \
"Atualização disponível do PJeCalc Cidadão..." "🔔 Sua versão do PJeCalc Cidadão está desatualizada.

Versão instalada:  $VERSAO_ATUAL 
Versão disponível: $VERSAO_SITE
"

else
      echo -e "\033[1;32m\n✅ PJeCalc Cidadão está na versão mais recente.\n \033[0m"

# notify-send  \
# -i "$logo" \
# -t 200000 \
# "PJeCalc Cidadão atualizado..." "\n✅ PJeCalc Cidadão está na versão mais recente.\n"

fi

sleep 10

exit 0
