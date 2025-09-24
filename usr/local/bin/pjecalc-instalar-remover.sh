#!/bin/bash
#
# Autores:
#
#   Bruno Goncalves <bigbruno@gmail.com>
#   Fernando Souza - https://www.youtube.com/@fernandosuporte/
#   Modificado por Pedro Henrique Quitete Barreto - pedrohqb@gmail.com
#   Homepage: https://github.com/pedrohqb/pjecalc-instalador
#   Licença:  MIT

titulo="Instalador não oficial do PJeCalc Cidadão"

# Priorizar formato SVG

logo="/usr/share/pixmaps/icone_calc.ico"

# URL da página de instalação

URL="https://www.trt8.jus.br/pjecalc-cidadao/instalando-o-pje-calc-cidadao"

# Logs de instalação

log="/tmp/pjecalc-instalador.log"

# Versões de referência do Java

VERSAO_MINIMA="11.0.25"
VERSAO_MAXIMA="24.0.1"

clear

rm -Rf "$log" 2>/dev/null

echo "=========== $(date '+%d-%m-%Y %H:%M:%S') - Início da instalação do PJeCalc Cidadão ==========" >> "$log"


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
verificar_programa netstat


# ----------------------------------------------------------------------------------------


# Mensagem sobre o arquivo de log

yad \
--center \
--title="Sobre o arquivo de Log" \
--window-icon="$logo" \
--image="$logo" \
--text="
O arquivo de log será criado em:

<b>$log</b>

Ele será responsável por identificar possíveis problemas com o programa PJeCalc Cidadão.

Em caso de erro, o arquivo de log deverá ser enviado para análise.

" \
--buttons-layout="center" \
--button=OK:0 \
--width="600" \
--height="100" \
2>/dev/null


# ----------------------------------------------------------------------------------------


# Função para converter versão para número (ex: 11.0.25 => 110025)

versao_para_numero() {

    echo "$1" | awk -F. '{ printf("%02d%02d%02d\n", $1, $2, $3) }'

}

# Detecta a versão atual do Java

JAVA_VERSION_RAW=$(java -version 2>&1 | awk -F\" '/version/ { print $2 }')


# Converte as versões para números inteiros

JAVA_NUM=$(versao_para_numero "$JAVA_VERSION_RAW")
MIN_NUM=$(versao_para_numero "$VERSAO_MINIMA")
MAX_NUM=$(versao_para_numero "$VERSAO_MAXIMA")


# Faz a comparação no if

if [ "$JAVA_NUM" -ge "$MIN_NUM" ] && [ "$JAVA_NUM" -lt "$MAX_NUM" ]; then

    echo "✅ Versão do Java $JAVA_VERSION_RAW é compatível."

    notify-send "PJeCalc Cidadão" -i "$logo" "\n✅ Versão do Java $JAVA_VERSION_RAW é compatível.\n"

else

    echo "❌ Versão do Java $JAVA_VERSION_RAW é incompatível."

    notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "\n❌ Versão do Java $JAVA_VERSION_RAW é incompatível.\n"

    exit

fi


# ----------------------------------------------------------------------------------------


verificar_internet(){

echo "
Testando conexão com à internet...
"

if ! ping -c 1 www.google.com.br -q &> /dev/null; then

    echo -e "\nSistema não tem conexão com à internet.\n" >> "$log"

    echo -e "\033[1;31m[ERRO] - Seu sistema não tem conexão com à internet. Verifique os cabos e o modem.\n \033[0m"
    
    sleep 10
    
    yad \
    --center \
    --window-icon "$logo" \
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

}


verificar_internet


# ----------------------------------------------------------------------------------------


clear

# Baixar o conteúdo da página e procurar o link do instalador

if [[ $(uname -m) == x86_64 ]]; then

# Instalador PJe-Calc Cidadão 64bits

echo -e "\nInstalador PJe-Calc Cidadão 64bits \n"

arch="x64"

VERSAO=$(curl -s "$URL" 2> /dev/null | grep -oP 'pjecalc-[0-9]+\.[0-9]+\.[0-9]+(?=-instalador-x64\.exe)' | head -n 1)

else

# Instalador PJe-Calc Cidadão 32bits

echo -e "\nInstalador PJe-Calc Cidadão 32bits \n"

arch="x32"

VERSAO=$(curl -s "$URL" 2> /dev/null | grep -oP 'pjecalc-[0-9]+\.[0-9]+\.[0-9]+(?=-instalador-x32\.exe)' | head -n 1)

fi

# Para verificar se a variavel é nula

if [ -z "$VERSAO" ];then

    echo -e "\033[1;31mVersão do PJeCalc Cidadão não identificada...\n \033[0m"

    exit

fi

# Filtrar

VERSAO=$(echo ""$VERSAO | cut -d"-" -f2)

# Exibir a versão do programa

echo -e "\nVersão mais recente do PJeCalc Cidadão: $VERSAO \n"

echo "
Versão mais recente do PJeCalc Cidadão: $VERSAO

Versão do Java: 

$(`which java` --version)


Arquitetura do processador: $(uname -m)

" >> "$log"

echo "
Sistema:
" >> "$log"

cat /etc/os-release  >> "$log"

sleep 5


# ----------------------------------------------------------------------------------------


if [ -e "$HOME/PjeCalc/bin/pjecalc.jar" ]; then

yad --center \
    --title="$titulo" \
    --window-icon="$logo" --image="$logo" \
    --text="O PJeCalc Cidadão já está instalado.\n\nDeseja reinstalar/atualizar o PJeCalc Cidadão ou removê-lo?" \
    --buttons-layout="center" \
    --button="Reinstalar ou atualizar o PJeCalc Cidadão":0 \
    --button="REMOVER o PJeCalc Cidadão!":1 \
    --width="800" --height="200"  2>/dev/null

    if [ "$?" = 1 ]; then

yad --center \
    --title="$titulo" \
    --window-icon="$logo" --image="$logo" \
    --text="Confirma que deseja REMOVER o PJeCalc Cidadão e os dados presentes no mesmo?" \
    --buttons-layout="center" \
    --button="Manter o PJeCalc Cidadão instalado":0 \
    --button="Confirmo, REMOVA o PJeCalc Cidadão!":1 \
    --width="800" --height="200"  2>/dev/null

            if [ "$?" = 1 ]; then


# ----------------------------------------------------------------------------------------


if [ -e "$HOME/PjeCalc/.dados" ]; then

                echo "
Realizando o backup da pasta $HOME/PjeCalc/.dados/
" | tee -a "$log"

sleep 1

                /usr/local/bin/pje_backup_restore.sh backup 2>> "$log"

fi


# ----------------------------------------------------------------------------------------


                rm -R "$HOME/PjeCalc" 2>> "$log"

                yad --center --title="$titulo" --window-icon="$logo" --image="$logo" --text="PJeCalc Cidadão removido!"  --buttons-layout="center" --button="OK" --width="400" --height="100" 2>/dev/null

            fi

            exit 0
    fi

fi

yad \
--center \
--title="$titulo" \
--window-icon="$logo" \
--image="$logo" \
--text="Esse é um instaldor não oficial para o programa PJeCalc Cidadão.

O PJeCalc Cidadão, oficialmente, possui instalador apenas para Windows, porém, é um
programa feito em java e funciona no Linux.

Para prosseguir, faça o download do PJeCalc Cidadão para Windows, e pressione 'Continuar'.

Na tela a seguir selecione o arquivo .exe do PJeCalc Cidadão.
Pode utilizar tanto a versão de 32 quanto a 64 bits.

" \
--buttons-layout="center" \
--button="Continuar":0 \
--button="Cancelar":1 \
--width="800" --height="200" \
2>/dev/null

if [ "$?" != 0 ]; then
	exit
fi

# Pergunta ao usuário com yad

yad --center \
    --title="Instalador do PJeCalc Cidadão" \
    --window-icon="$logo" --image="$logo" \
    --text=$"Deseja baixar a versão mais recente do PJeCalc Cidadão na pasta $HOME?\n\nArquivo: pjecalc-$VERSAO-instalador-$arch.exe" \
    --buttons-layout="center" \
    --button="Sim, baixar agora":0 \
    --button="Cancelar":1 \
    --width="400" \
    2>/dev/null

# Verifica resposta do usuário

if [ $? -eq 0 ]; then

    # Baixa o arquivo com wget (salvar o arquivo pjecalc-$VERSAO-instalador-$arch.exe na pasta $HOME)

    echo -e "\033[1;32m\nBaixando o arquivo pjecalc-$VERSAO-instalador-$arch.exe na pasta $HOME \n\n\033[0m"
    
    sleep 2

    # Salvando em: "/home/biglinux/pjecalc-2.13.2-instalador-x64.exe" 269M

    wget -O "$HOME/pjecalc-$VERSAO-instalador-$arch.exe" -c "https://www.trt8.jus.br/sites/portal/files/roles/pje-calc/pjecalc-$VERSAO-instalador-$arch.exe" && \
    yad --center --title="Download concluído" --window-icon="$logo" --image="$logo" --text="Download concluído com sucesso!" --buttons-layout="center" --button="OK"  --width="400" --height="100" 2>/dev/null

else

    yad --center --title="Download cancelado" --window-icon="$logo" --image="$logo" --text="O download foi cancelado pelo usuário." --buttons-layout="center" --button="OK"  --width="400" --height="100" 2>/dev/null

fi

# Verificar se o PJeCalc já está em execução

if pgrep -f "pjecalc.jar" &>/dev/null; then

# Pega o PID do processo Java que roda o pjecalc.jar e o finaliza com kill -9 se o processo for teimoso.

ps aux | grep pjecalc.jar | grep java | awk '{print $2}' | xargs -r kill -9

echo -e "\033[1;31m\nO PJeCalc Cidadão já está em execução....\n \033[0m"

yad \
--center  \
--title="Aviso" \
--window-icon="dialog-error" \
--image="dialog-error" \
--text="O PJeCalc Cidadão já está em execução." \
--buttons-layout="center" \
--button="OK":0 \
--width="300" --height="100" \
2>/dev/null

fi

rm -Rf "$HOME/.pjecalc-instalando/" 2>> "$log"

mkdir -p ~/.pjecalc-instalando  2>> "$log" || echo -e "\033[1;31m\nFalha ao criar a pasta $HOME/.pjecalc-instalando. \n \033[0m"

# Abre o gerenciador de arquivos, define a pasta $HOME como padrão e filtra apenas arquivos .exe.

ARQUIVO=$(yad --center --title="$titulo" --window-icon="$logo" --image="$logo" --file --filename="$HOME/" --file-filter="Arquivos .exe | *.exe" --buttons-layout="center" --button="Cancelar":1 --button="OK":0 --width="1200" --height="800"  2>/dev/null)


# ----------------------------------------------------------------------------------------


# Recebe o caminho do arquivo como argumento.

CAMINHO="$ARQUIVO" # Agora o shell entende tudo como um único valor.

# Verifica se o argumento foi fornecido

if [ -z "$CAMINHO" ]; then

    echo -e "\033[1;31m\n❌ Por favor, forneça o caminho completo do arquivo. \n\033[0m"

        yad --center \
            --title="Atenção" \
            --window-icon="$logo" \
            --image=dialog-warning \
            --text="❌ Por favor, forneça o caminho completo do arquivo." \
            --buttons-layout="center" \
            --button="OK":0 \
            --width="600" --height="150" \
            2> /dev/null

    exit 1
fi

# Caracteres especiais a verificar

CARACTERES_ESPECIAIS='[&|;<>*?()\[\]{}$#!\`'"'"'\"~ /çáéíóúãõâêîôûÁÉÍÓÚÃÕÂÊÎÔÛÇ]'

# Verifica se o caminho contém algum dos caracteres especiais

if [[ "$CAMINHO" =~ $CARACTERES_ESPECIAIS ]]; then

    echo -e "\033[1;31m\n⚠️  O caminho contém caracteres especiais: \n$CAMINHO\n\033[0m"

        yad --center \
            --title="Atenção" \
            --window-icon="$logo" \
            --image=dialog-warning \
            --text="O caminho contém caracteres especiais: \n$CAMINHO\n" \
            --buttons-layout="center" \
            --button="OK":0 \
            --width="600" --height="150" \
            2> /dev/null

    exit

else

    echo -e "\033[1;32m\n✅ O caminho NÃO contém caracteres especiais. \n$CAMINHO \n\033[0m"

fi

ARQUIVO="$CAMINHO"


# ----------------------------------------------------------------------------------------


# Versão mais recente do PJe-Calc no site oficial: 

# Criar diretório de instalação

if mkdir -p "$HOME/PjeCalc" 2>> "$log"; then

    # Adiciona no arquivo $HOME/PjeCalc/versao_instalada.txt a versão recente do site.

    echo "$VERSAO" > "$HOME/PjeCalc/versao_instalada.txt"

else

    echo -e "\033[1;31m\nFalha ao criar diretório de instalação: $HOME/PjeCalc \n\033[0m"

        yad --center \
            --title="Atenção" \
            --window-icon="$logo" \
            --image=dialog-warning \
            --text="Falha ao criar diretório de instalação: $HOME/PjeCalc" \
            --buttons-layout="center" \
            --button="OK":0 \
            --width="600" --height="150" \
            2> /dev/null

        exit

fi


# ----------------------------------------------------------------------------------------


# Versão do PJeCalc com base no arquivo .exe fornecedo pelo usuário.

# Verificar se o arquivo .exe contém a palavra pjecalc no nome.

# O Bash diferencia maiúsculas de minúsculas por padrão. NÃO vai detectar PJeCalc, Pjecalc, PJECalc, etc.

# Solução que funciona com qualquer variação de maiúsculas/minúsculas:

if echo "$ARQUIVO" | grep -iq "pjecalc"; then

    echo -e "\nO arquivo contém 'pjecalc' no nome.\n"

# Pega a versão do PJe-Calc com base no arquivo .exe fornecido pelo o usuário: 

# Ex: pjecalc-2.13.2-instalador-x64.exe


# Adiciona no arquivo $HOME/PjeCalc/versao_instalada.txt a versão do PJeCalc que esta no nome do arquivo .exe

echo "$ARQUIVO" | grep -oP '(?<=pjecalc-)\d+\.\d+\.\d+' > $HOME/PjeCalc/versao_instalada.txt


# Verificar se o conteúdo do arquivo ~/PjeCalc/versao_instalada.txt é igual ao valor da variável $VERSAO.

# Se não for igual, exibir um aviso com o yad (interface gráfica) informando que o usuário está tentando instalar uma versão desatualizada.

# Verifica se o arquivo existe

if [[ -f "$HOME/PjeCalc/versao_instalada.txt" ]]; then

    VERSAO_ARQUIVO=$(<"$HOME/PjeCalc/versao_instalada.txt")

    # O bloco if será executado apenas quando a versão do arquivo .exe for menor que a versão do site ($VERSAO), e não apenas diferente.

    if [[ "$(printf '%s\n' "$VERSAO_ARQUIVO" "$VERSAO" | sort -V | head -n1)" == "$VERSAO_ARQUIVO" && "$VERSAO" != "$VERSAO_ARQUIVO" ]]; then

        echo -e "\033[1;31m\nA versão do arquivo ($VERSAO_ARQUIVO) é menor que a versão do site ($VERSAO) \n\033[0m"

        yad --center \
            --title="Atenção" \
            --window-icon="$logo" \
            --image=dialog-warning \
            --text="Você está tentando instalar a versão <b>$VERSAO_ARQUIVO</b>, mas a versão atual no site do PJeCalc Cidadão é <b>$VERSAO</b>.\n\nIsso pode sobrescrever uma versão mais recente!" \
            --buttons-layout="center" \
            --button="Cancelar":1 \
            --button="OK":0 \
            --width="700" --height="150" \
            2> /dev/null

        if [ "$?" != 0 ]; then

	        exit

        fi

    fi

else

    echo -e "\033[1;31m\nArquivo $HOME/PjeCalc/versao_instalada.txt não encontrado. \n\033[0m"

fi

else

    echo -e "\033[1;31m\nO arquivo $ARQUIVO NÃO contém 'pjecalc' no nome. \n\033[0m"

fi


# ----------------------------------------------------------------------------------------


# Verificar se o arquivo .exe do PJeCalc foi fornecido

if [ -n "$ARQUIVO" ]; then

    cp -f "$ARQUIVO" "$HOME/.pjecalc-instalando/pjecalc.exe" 2>> "$log" || echo -e "\033[1;31m\nFalha ao copiar o arquivo $ARQUIVO para a pasta $HOME/.pjecalc-instalando/  \n \033[0m"

fi


# Verificar se o arquivo .exe existe

if ! [ -e "$HOME/.pjecalc-instalando/pjecalc.exe" ]; then

    echo -e "\033[1;31m\nO arquivo $HOME/.pjecalc-instalando/pjecalc.exe não existe. \n \033[0m"

yad \
--center  \
--title="Aviso" \
--window-icon="dialog-error" \
--image="dialog-error" \
--text="O arquivo $HOME/.pjecalc-instalando/pjecalc.exe não existe." \
--buttons-layout="center" \
--button="OK":0 \
--width="600" --height="100" \
2>/dev/null

    exit

fi


# ----------------------------------------------------------------------------------------


# Descompactar o arquivo .exe

cd "$HOME/.pjecalc-instalando/" 2>> "$log" || {

    echo -e "\033[1;31m\n❌ Falha ao acessar o diretório de instalação: $HOME/.pjecalc-instalando/\n\033[0m"

        yad \
        --center \
        --title="ERRO" \
        --window-icon=dialog-warning \
        --text="\n❌ Falha ao acessar o diretório de instalação: $HOME/.pjecalc-instalando/ \n" \
        --buttons-layout="center" \
        --button="OK" \
        --width="640" \
        2>/dev/null

    exit 1
}


# Tentar descompactar com 7z, e se falhar, registrar o erro no arquivo de log.

7z x pjecalc.exe 2>> "$log" || {

    echo -e "\033[1;31m\n❌ Falha ao descompactar o arquivo pjecalc.exe com 7z.\n\033[0m"

        yad \
        --center \
        --title="ERRO" \
        --window-icon=dialog-warning \
        --text="\n❌ Falha ao descompactar o arquivo <b>pjecalc.exe</b> com <b>7z</b>.\n" \
        --buttons-layout="center" \
        --button="OK" \
        --width="640" \
        2>/dev/null


    exit 1

}


# ----------------------------------------------------------------------------------------


# Remoção do arquivo .exe


# Janela de confirmação

yad \
--center \
--title="Confirmar Remoção" \
--window-icon="$logo" --image="$logo" \
--text="Deseja remover o arquivo .exe baixado?" \
--width=300 \
--buttons-layout="center" \
--button=Não:1 --button=Sim:0 --width="400" --height="100" 2>/dev/null


# Verifica a escolha do usuário

if [ $? -eq 0 ]; then

    rm $HOME/pjecalc-$VERSAO-instalador-$arch.exe 2>> "$log" && \
    rm pjecalc.exe 2>> "$log" && \
    yad --center --title="Removido" --window-icon="$logo" --image="$logo" --text="Arquivo <b>pjecalc.exe</b> removido com sucesso!" --buttons-layout="center" --button=OK --width="400" --height="100" 2>/dev/null

else

    yad --center --title="Cancelado" --window-icon="$logo" --image="$logo" --text="Ação cancelada pelo usuário." --buttons-layout="center" --button=OK --width="400" --height="100" 2>/dev/null

fi


# ----------------------------------------------------------------------------------------


rm -Rf pjecalc-*/navegador 2>> "$log" || echo -e "\033[1;31m\nFalha ao remove os arquivos... \n \033[0m"

rm -Rf pjecalc-*/bin/jre   2>> "$log" || echo -e "\033[1;31m\nFalha ao remove os arquivos... \n \033[0m"


# Criar diretório de instalação

mkdir -p ~/PjeCalc 2>> "$log" ||  echo -e "\033[1;31m\nFalha ao criar diretório de instalação $HOME/PjeCalc.\n \033[0m"


# Copiar o arquivo .exe para o diretório de instalação

cp -Rf pjecalc-*/* "$HOME/PjeCalc" 2>> "$log" || echo -e "\033[1;31m\nFalha ao copiar os arquivos para pasta $HOME/PjeCalc \n \033[0m"

if [ -e "$HOME/PjeCalc/.dados" ]; then

yad --center \
    --title="$titulo" \
    --window-icon="$logo" --image="$logo" \
    --text="Detectei que já existe uma base de dados do PJeCalc Cidadão nesse computador,\ndeseja manter os dados atuais ou efetuar uma instalação limpa?" \
    --buttons-layout="center" \
    --button="MANTER MEUS DADOS":0 \
    --button="APAGAR MEUS DADOS":1 \
    --width="800" --height="200"  2>/dev/null

    if [ "$?" = 1 ]; then

yad --center \
    --title="$titulo" \
    --window-icon="$logo" --image="$logo" \
    --text="Confirma que deseja apagar os dados preenchidos no PJeCalc Cidadão?" \
    --buttons-layout="center" \
    --button="Não apague os dados":0 \
    --button="Confirmo, apague os dados!":1 \
    --width="800" --height="200"  2>/dev/null

            if [ "$?" = 1 ]; then

                rm -R "$HOME/PjeCalc/.dados" 2>> "$log" || echo -e "\033[1;31m\nFalha ao remove a pasta $HOME/PjeCalc/.dados \n \033[0m"

                cp -Rf pjecalc-*/.dados "$HOME/PjeCalc/.dados" 2>> "$log" || echo -e "\033[1;31m\nFalha ao copiar os arquivos para pasta $HOME/PjeCalc/.dados \n \033[0m"

            fi
    fi

else

    cp -Rf pjecalc-*/.dados "$HOME/PjeCalc/.dados" 2>> "$log" || echo -e "\033[1;31m\nFalha ao copiar os arquivos para pasta $HOME/PjeCalc/.dados \n \033[0m"

fi


rm -Rf "$HOME/.pjecalc-instalando/" 2>> "$log" || echo -e "\033[1;31m\nFalha ao remove a pasta $HOME/.pjecalc-instalando \n \033[0m"


# ----------------------------------------------------------------------------------------


# Verificar se o usuário tem acesso ao arquivo PjeCalc/.dados/pjecalc.h2.db

ARQUIVO_PjeCalc="$HOME/PjeCalc/.dados/pjecalc.h2.db"

# Verificar se o arquivo pjecalc.h2.db existe

if [ -f "$ARQUIVO_PjeCalc" ]; then

    echo "✅ O arquivo existe: $ARQUIVO_PjeCalc"

if [ -r "$ARQUIVO_PjeCalc" ] && [ -w "$ARQUIVO_PjeCalc" ]; then


    echo -e "\033[1;32m\n✅ O usuário tem acesso de leitura e escrita ao arquivo: $ARQUIVO_PjeCalc \n\033[0m"

    notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "\n✅ O usuário tem acesso de leitura e escrita ao arquivo: $ARQUIVO_PjeCalc\n"

else

    echo -e "\033[1;31m❌ Sem permissão para acessar (ler ou escrever) o arquivo: $ARQUIVO_PjeCalc\033[0m"

    yad --center --title="PJeCalc Cidadão" --window-icon=dialog-warning --image="$logo" --text="❌ Sem permissão para acessar (ler ou escrever) o arquivo: $ARQUIVO_PjeCalc" --buttons-layout="center"  --button="OK" --width="500" 2>/dev/null

    # exit
fi


else

    echo -e "\033[1;31m❌ O arquivo não existe: $ARQUIVO_PjeCalc\033[0m"

    yad --center --title="PJeCalc Cidadão" --window-icon=dialog-warning --image="$logo" --text="❌ O arquivo não existe: $ARQUIVO_PjeCalc" --buttons-layout="center"  --button="OK" --width="500" 2>/dev/null

    # exit

fi



# Fonte:

# https://www.trt8.jus.br/pjecalc-cidadao/perguntas-frequentes-duvidas-tecnicas


# ----------------------------------------------------------------------------------------


if [ -e "$HOME/PjeCalc/bin/pjecalc.jar" ]; then

echo -e "\033[1;32m\nPJeCalc Cidadão instalado com sucesso! \n\033[0m"

yad \
--center \
--title="Instalação concluída"  \
--window-icon="$logo" \
--image="$logo" \
--text="
O <b>PJeCalc Cidadão</b> foi instalado na pasta <b>$HOME/PjeCalc</b> se você apagar ou modificar o nome dessa 
pasta o <b>PjeCalc</b> não irá funcionar.

Para utilizar o <b>PJeCalc Cidadão</b>, abra-o no menu do sistema na categoria <b>Escritório</b>.


Foi adicionado um atalho para <b>documentação online do PJeCalc Cidadão</b>.

Menu iniciar => Internet => Manual do PJe
" \
--buttons-layout="center" \
--button=OK  \
--width="800" --height="200"  \
2>/dev/null


# ----------------------------------------------------------------------------------------


echo "
Baixa as Tabelas Auxiliares (.idc)
"

# Diretório onde salvar o arquivo

DESTINO="$HOME/PjeCalc"

mkdir -p "$DESTINO"


# Página com o link

PAGINA="https://www.trt8.jus.br/pjecalc-cidadao/tabelas-auxiliares-trt8"

# Extrai o link .idc

REL_LINK=$(curl -s "$PAGINA" | grep -oE 'href="(/sites/portal/files/roles/pje-calc/tabelasnacionaisregionais[0-9]+\.idc)"' | head -1 | cut -d'"' -f2)

if [ -n "$REL_LINK" ]; then
    FULL_LINK="https://www.trt8.jus.br$REL_LINK"
    FILENAME=$(basename "$REL_LINK")

    # Caixa de diálogo com YAD
    yad --center \
        --title="Download das tabelas auxiliares do PJeCalc Cidadão TRT8" \
        --text="Deseja baixar o arquivo: <b>$FILENAME</b>?" \
        --buttons-layout="center" \
        --button="Baixar:0" --button="Cancelar:1" \
        --width="700" --height="200" \
        2>/dev/null

    # Verifica o código de saída do YAD

    if [ $? -eq 0 ]; then

        wget -P "$DESTINO" -c "$FULL_LINK" && \
        yad --info --center --title="Tabelas auxiliares" --text="✅ Arquivo baixado com sucesso:\n$DESTINO/$FILENAME" --buttons-layout="center"  --button="OK" --width="700" 2>/dev/null

    else

        yad --info --center --title="Tabelas auxiliares" --text="🚫 Download cancelado pelo usuário." --buttons-layout="center"  --button="OK" --width="500" 2>/dev/null

    fi

else

    yad --error --center --title="Tabelas auxiliares" --text="❌ Nenhum link .idc encontrado na página." --buttons-layout="center"  --width="500"--button="OK" 2>/dev/null

fi


# ----------------------------------------------------------------------------------------


else

    yad --center --title="$titulo" --window-icon="$logo" --image="$logo" --text="A instalação não foi realizada com sucesso!"  --buttons-layout="center" --button=OK --width="400" --height="100" 2>/dev/null

fi

exit 0
