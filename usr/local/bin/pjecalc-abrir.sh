#!/bin/bash
#
# Autores:
#
#   Bruno Goncalves <bigbruno@gmail.com>
#   Fernando Souza - https://www.youtube.com/@fernandosuporte/
#   Modificado por Pedro Henrique Quitete Barreto - pedrohqb@gmail.com
#   Homepage: https://github.com/pedrohqb/pjecalc-instalador
#   Licença:  MIT

logo="/usr/share/pixmaps/icone_calc.ico"


# Versões de limite do Java

VERSAO_MINIMA="11.0.25"

VERSAO_MAXIMA="24.0.1"


# Porta

porta="9257"


# Logs de execução

log="/tmp/pjecalc.log"


clear


# Remove o arquivo de log

rm -Rf "$log" 2>/dev/null


# ----------------------------------------------------------------------------------------

# Garantir que o shell use a codificação correta no início do script.

export LANG=pt_BR.UTF-8

export LC_ALL=pt_BR.UTF-8

# ----------------------------------------------------------------------------------------


INICIO=$(echo "=========== $(date '+%d-%m-%Y %H:%M:%S') - Início da execução do PJeCalc Cidadão ==========")

echo  "

$INICIO

" >> "$log"


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
verificar_programa find
verificar_programa iconv
verificar_programa sed


# find /usr/share/icons/ -iname *gtk-dialog*


# ----------------------------------------------------------------------------------------

# Verificação automática do Java


verifica_java(){

# Tenta encontrar Java na pasta /usr/lib/jvm

jvm_base="/usr/lib/jvm"

java_dir=$(ls "$jvm_base" 2>/dev/null | grep openjdk | head -n1)

if [ -n "$java_dir" ] && [ -x "$jvm_base/$java_dir/bin/java" ]; then

    JAVA_PATH="$jvm_base/$java_dir/bin/java"

else

    # Caso falhe, tenta descobrir via which + readlink

    java_bin=$(which java 2>/dev/null)

    if [ -n "$java_bin" ]; then

        JAVA_PATH=$(readlink -f "$java_bin")

    fi
fi


}


verifica_java


# Verifica se encontrou

if [ -x "$JAVA_PATH" ]; then

    echo -e "\nJava encontrado em: $JAVA_PATH \n\n"

else

    yad --center \
        --title="Erro ao localizar Java" \
        --window-icon=dialog-warning \
        --image="$logo" \
        --text="Não foi possível localizar uma instalação válida do Java." \
        --buttons-layout="center" \
        --button="OK" --width="300"

    exit 1
fi


# Agora você pode usar $JAVA_PATH normalmente:

"$JAVA_PATH" -version | tee -a "$log"


# ----------------------------------------------------------------------------------------


# Verificando se o caminho existe antes de usar:

if [ -x "$JAVA_PATH" ]; then

    java="$JAVA_PATH"

else

    yad --center --title="Erro" --window-icon=dialog-warning --image="$logo" --text="Java não encontrado em $JAVA_PATH" --buttons-layout="center" --button="OK"  2>/dev/null

    exit 1

fi


# ----------------------------------------------------------------------------------------


# Função para converter versão em número comparável

versao_para_numero() {

    echo "$1" | awk -F. '{ printf("%02d%02d%02d\n", $1, $2, $3) }'

}


# Verifica se Java está disponível

if ! command -v "$JAVA_PATH" &> /dev/null; then
    echo "❌ Java não encontrado no PATH."
    exit 1
fi

# Captura a versão do Java

JAVA_VERSION_RAW=$("$JAVA_PATH" -version 2>&1 | awk -F\" '/version/ { print $2 }')

# Verifica se conseguiu pegar a versão

if [ -z "$JAVA_VERSION_RAW" ]; then

    echo "❌ Não foi possível detectar a versão do Java."

    notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "❌ Não foi possível detectar a versão do Java."

    exit 1
fi

echo "🔍 Versão do Java detectada: $JAVA_VERSION_RAW"

# notify-send "PJeCalc Cidadão" "🔍 Versão do Java detectada: $JAVA_VERSION_RAW"


# Converte para formato numérico

JAVA_NUM=$(versao_para_numero "$JAVA_VERSION_RAW")
MIN_NUM=$(versao_para_numero "$VERSAO_MINIMA")
MAX_NUM=$(versao_para_numero "$VERSAO_MAXIMA")

# Compara versões

if [ "$JAVA_NUM" -lt "$MIN_NUM" ]; then

    echo "❌ Versão do Java menor que a mínima exigida ($VERSAO_MINIMA)."

    notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "❌ Java menor que a versão mínima exigida ($VERSAO_MINIMA)."

    exit 1

elif [ "$JAVA_NUM" -ge "$MAX_NUM" ]; then

    echo "❌ Versão do Java maior ou igual à máxima permitida ($VERSAO_MAXIMA)."

    notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "❌ Java maior ou igual à versão máxima permitida ($VERSAO_MAXIMA)."

    exit 1

else

    echo "✅ Versão do Java é compatível com o PJeCalc Cidadão."

    notify-send "PJeCalc Cidadão" -i "$logo" "✅ Versão do Java é compatível. Iniciando o programa..."

    echo "🚀 Iniciando o programa..."

fi


# ----------------------------------------------------------------------------------------


if ! [ -e "$HOME/PjeCalc/bin/pjecalc.jar" ]; then


yad --center \
    --title="PJeCalc Cidadão não instalado!" \
    --window-icon=dialog-warning --image="$logo" \
    --text="O PJeCalc Cidadão ainda não está instalado." \
    --buttons-layout="center" \
    --button="OK" \
    --width="400" \
    2>/dev/null

    clear

    exit 1

fi


# ----------------------------------------------------------------------------------------


# Verificar acesso a pasta $HOME/PjeCalc

verificar_acesso(){


PASTA="$HOME/PjeCalc"

# Cores
VERDE="\033[0;32m"
VERMELHO="\033[0;31m"
AMARELO="\033[1;33m"
RESET="\033[0m"

# Verifica se a pasta existe

if [ ! -d "$PASTA" ]; then

    echo -e "${VERMELHO}❌ Pasta não encontrada: $PASTA${RESET}"

    notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "\nPasta não encontrada: $PASTA\n"

    exit 1
fi

# Verifica permissões na pasta

if [ -r "$PASTA" ] && [ -w "$PASTA" ]; then

    echo -e "${VERDE}✅ Você tem permissão de leitura e escrita na pasta: $PASTA${RESET}"

else

    echo -e "${AMARELO}⚠️  Sem permissão total na pasta: $PASTA${RESET}"

    notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "\nSem permissão total na pasta: $PASTA\n"

fi


}


verificar_acesso


# ----------------------------------------------------------------------------------------


# Mensagem sobre o arquivo de log


echo "

O que é PJeCalc Cidadão?

O PJe-Calc Cidadão é o sistema desenvolvido pela Secretaria de Tecnologia da Informação do Tribunal Regional do Trabalho 
da 8ª Região (PA/AP), a pedido do Conselho Superior da Justiça do Trabalho (CSJT), para utilização em toda a Justiça do Trabalho 
como ferramenta padrão de elaboração de cálculos trabalhistas e liquidação de sentenças, visando à uniformidade de procedimentos 
e à confiabilidade nos resultados apurados.



O arquivo de log será criado em:

$log

Ele será responsável por identificar possíveis problemas com o programa PJeCalc Cidadão.

Em caso de erro, o arquivo de log deverá ser enviado para análise.

----------------------------------------------------
PJe Office + PJeCalc Cidadão + Navegador = Tudo se conecta.
----------------------------------------------------


Obs: Oficialmente o PJeCalc Cidadão é compatível apenas com o Firefox - pelo menos quando integrado com o PJe Office e o sistema de cálculo da 
Justiça do Trabalho.

O PJeCalc Cidadão em si é uma aplicação Java independente, usada para fazer cálculos trabalhistas e gerar documentos. No entanto, ele frequentemente 
depende do PJe Office, que é o módulo de autenticação com certificado digital, necessário para funcionar em conjunto com o sistema PJe 
(Processo Judicial Eletrônico).

Por que Firefox?

   - O PJeCalc Cidadão é homologado oficialmente só para o Firefox.

   - O Firefox ainda permite (em parte) o uso de integrações por socket (ex: via localhost:9999) que outros navegadores como Chrome e Edge 
bloqueiam ou restringem.

   - Os tribunais, como o TRT, normalmente só testam e dão suporte oficial ao Firefox.

   
Obs: A funcionalidade de importação de arquivos locais não abre no gerenciador de arquivo do KDE (Dolphin) no Firefox 128.9.0 ESR (64 bits). Ao tentar importar um arquivo, o processo não é iniciado. No entanto, a mesma funcionalidade funciona normalmente ao utilizar o navegador Brave (versão 1.62.165 - Chromium: 121.0.6167.184, 64 bits)  não foi testado em outros navegadores baseados no Chromium.

Obs: O Pje-Calc Cidadão usa Firefox Portable versão 55.0.2 no Windows.


E se usar outro navegador?

   - Pode até conseguir abrir o PJeCalc Cidadão.

   - Mas a comunicação com o PJe Office e a assinatura digital geralmente não funciona.

   - Vai falhar na hora de validar certificado, assinar documentos ou transmitir os dados de volta ao sistema PJe.

Se você quiser rodar o PJeCalc Cidadão de forma offline, sem ligação com navegador ou certificado, aí qualquer navegador serve — ou nenhum! Só o Java.


O que funciona no modo offline:

✔️ Criar cálculos
✔️ Gerar PDFs
✔️ Exportar XML
✔️ Ver históricos
❌ Assinar com certificado digital (sem PJe Office)
❌ Enviar para o sistema PJe automaticamente



Consultar o suporte técnico: 

Se o problema persistir, é aconselhável entrar em contato com o suporte técnico do PJe-Calc Cidadão ou 
com o setor de tecnologia da informação do TRT da sua região para assistência adicional.


" \
| yad \
--center \
--title="Sobre o PJe-Calc" \
--image="$logo" \
--window-icon=dialog-warning \
--text-info \
--buttons-layout="center" \
--button=OK:0 \
--width="1200" \
--height="800" \
2>/dev/null



# https://pjecalccalculos.com.br/


# ----------------------------------------------------------------------------------------


# Verificar se o Firefox esta instalado.

if command -v firefox > /dev/null 2>&1; then


# ----------------------------------------------------------------------------------------


# Vamos matar o Firefox se ele estiver aberto.

if pgrep -x firefox > /dev/null; then


    echo -e "\033[1;31m\n[ERRO] - ❌ Firefox está rodando. Matando o processo... \n\033[0m"

    yad --center --title="Encerrando Firefox" \
        --text="O Firefox está em execução e será encerrado para abrir o PJeCalc Cidadão." \
        --image=dialog-warning --buttons-layout="center" --button="OK" --width="700" 2>/dev/null

    pkill -x firefox


else

    echo -e "\033[1;32m\nFirefox não está em execução.... \n\033[0m"

fi


# ----------------------------------------------------------------------------------------


    echo -e "\033[1;32m\nFirefox encontrado. Abrindo PJeCalc Cidadão... \n\033[0m"
    
else

    echo -e "\033[1;31m[ERRO] - ❌ Firefox não está instalado para abrir o PJeCalc Cidadão.\n\nPor favor, instale. \033[0m"

        yad \
        --center \
        --title="Firefox não encontrado" \
        --window-icon=dialog-warning \
        --text="❌ O navegador Firefox não está instalado para abrir o PJeCalc Cidadão.\n\nPor favor, instale-o <b>usando o gerenciador de pacotes da sua distribuição Linux.</b>" \
        --buttons-layout="center" \
        --button="OK" \
        --width="640" \
        2>/dev/null




    exit 1

fi


# ----------------------------------------------------------------------------------------


# Para finalizar o processo associado ao pjecalc.jar.

pkill -f pjecalc.jar 2>/dev/null

sleep 1


# ----------------------------------------------------------------------------------------


# Verifica se a porta está em uso.

OCUPADA=$(netstat -tuln 2>/dev/null | grep ":$porta ")

if [ -n "$OCUPADA" ]; then

    echo -e "\033[1;31m\n⚠️  A porta $porta está em uso:\n$OCUPADA \n \033[0m"

    yad --center --window-icon=dialog-warning --image="$logo" --title="PJeCalc Cidadão" --text="\nA porta $porta está em uso:\n$OCUPADA \n" --buttons-layout="center" --button="OK" --width="500" 2>/dev/null


    # Descobre o PID usando a porta.

    PID=$(fuser $porta/tcp 2>/dev/null)

    if [ -n "$PID" ]; then

        echo -e "\033[1;31m\n🔍 Processo usando a porta: PID $PID \n \033[0m"


        # Diálogo com yad para confirmação

        yad \
            --center \
            --title="Porta em Uso" \
            --text="⚠️ A porta $porta está em uso pelo processo PID $PID.\n\nDeseja finalizar esse processo?" \
            --buttons-layout="center" \
            --button="Finalizar Processo:0" --button="Cancelar:1" \
            --width="500" \
            --height="200" \
            2>/dev/null


        # Verifica o código de saída do yad (0 = botão 1 foi clicado)

        if [ $? -eq 0 ]; then

            # kill -9 $PID 2>/dev/null

            killall -9 $PID 2>/dev/null

            # yad --center --info --title="Sucesso" --text="✅ Processo $PID que estava usando a porta $porta foi finalizado com sucesso." --buttons-layout="center" --button="OK" 2>/dev/null

            notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "\n✅ Processo $PID que estava usando a porta $porta foi finalizado com sucesso.\n"

        else

            yad --center --info --title="Cancelado" --text="ℹ️ Processo $PID não foi finalizado." --buttons-layout="center" --button="OK" --width="300" 2>/dev/null

        fi

    else

        # yad --center --warning --title="Erro" --text="❌ Não foi possível identificar o processo com fuser." --buttons-layout="center" --button="OK" --width="400" 2>/dev/null

        notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "\n❌ Não foi possível identificar o processo com fuser.\n"


    fi

else

    # yad --center --info --title="Porta Livre" --text="✅ A porta $porta está livre." --buttons-layout="center" --button="OK" --width="300" 2>/dev/null

    notify-send "Porta Livre" -i "$logo" -t 100000 "\n✅ A porta $porta está livre para ser usada no PJeCalc Cidadão...\n"
fi


# Fonte:

# https://www.trt8.jus.br/pjecalc-cidadao/perguntas-frequentes-duvidas-tecnicas



# ----------------------------------------------------------------------------------------


cd "$HOME/PjeCalc/" 2>> "$log" || exit


# Esse trecho do script está verificando se o pjecalc.jar não está rodando. Se não estiver, ele inicia o programa usando Java.

# https://www.youtube.com/watch?v=GIqSTTuOBwM


if [ "$(ps -aux | grep -i pjecalc.jar | grep java)" = "" ]; then


    # Iniciar o PJeCalc Cidadão

    echo -e "\033[1;32m\nIniciando o PJeCalc Cidadão... \n\033[0m"

    echo "
Iniciando o PJeCalc Cidadão...

" >> "$log"



   # exec "$JAVA_PATH" -Duser.timezone=GMT-3 -Dfile.encoding=ISO-8859-1 -Dseguranca.pjecalc.tokenServicos=pW4jZ4g9VM5MCy6FnB5pEfQe -Xms1024m -Xmx2048m -XX:MaxPermSize=512m -jar bin/pjecalc.jar  2>> "$log" &


   # Redirecionamento de erros (tudo (stdout + stderr) vá para o log)

  exec "$JAVA_PATH" \
  -splash:pjecalc_splash.gif \
  -Duser.timezone=GMT-3 \
  -Dfile.encoding=ISO-8859-1 \
  -Dseguranca.pjecalc.tokenServicos=pW4jZ4g9VM5MCy6FnB5pEfQe \
  -Dseguranca.pjekz.servico.contexto="https://pje.trtXX.jus.br/pje-seguranca" \
  -Xms1024m \
  -Xmx2048m \
  -jar bin/pjecalc.jar 2>> "$log" &


# ----------------------------------------------------------------------------------------


fi


ESPERAR=1

while [  $ESPERAR = 1 ]; do

    curl http://localhost:$porta/pjecalc 2> /dev/null

    if [ "$?" = 0 ]; then

        ESPERAR=0


        # O PJe Office é homologado oficialmente só para o Firefox.

        exec firefox http://localhost:$porta/pjecalc 2>> "$log" &

    fi

    sleep 1

done


# ----------------------------------------------------------------------------------------


# Verificar se a porta 9257 no localhost está aberta e ouvindo (ou seja, se o programa no http://localhost:9257 está ativo).


if curl -s --head http://localhost:$porta | grep "HTTP/" ; then


    echo -e "\nO programa está ativo na porta $porta.\n"


else


    echo -e "\033[1;31m\n❌ A porta $porta não está respondendo como esperado.\n \033[0m"

    yad --center --title="PJeCalc Cidadão" --window-icon=dialog-warning --image="$logo" --text="O PJeCalc Cidadão não está acessível em http://localhost:$porta \n\nVerifique se ele está em execução." --buttons-layout="center"  --button="OK" --width="500" 2>/dev/null
    
    
fi


# ----------------------------------------------------------------------------------------


# Arquivo compactado de tabelas auxiliares


ARQUIVO_IDC=$(find "$HOME/PjeCalc/" -type f -iname "*.IDC" 2>/dev/null)

if [ -n "$ARQUIVO_IDC" ]; then

    echo -e "\033[1;32m\n✅ Arquivo(s) .IDC encontrado(s): \n\033[0m"

    echo "$ARQUIVO_IDC"

else

    echo -e "\033[1;31m\n❌ Nenhum arquivo .IDC encontrado em $HOME/PjeCalc/ \n\nhttps://www.trt8.jus.br/pjecalc-cidadao/tabelas-auxiliares-trt8 \n\033[0m"

    notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "\n❌ Nenhum arquivo .IDC encontrado em $HOME/PjeCalc/ \n\nhttps://www.trt8.jus.br/pjecalc-cidadao/tabelas-auxiliares-trt8 \n"


fi


# ----------------------------------------------------------------------------------------


notify-send "PJeCalc Cidadão" -i "$logo" -t 100000 "\nEm caso de problemas, verifique o arquivo de log: $log. \n\nA documentação de ajuda em formato PDF encontra-se na pasta /usr/share/doc/pjecalc-instalador/"


# ----------------------------------------------------------------------------------------


# Converter o arquivo pjecalc.log para UTF-8 sem gerar um novo arquivo

iconv -f ISO-8859-1 -t UTF-8 /tmp/pjecalc.log -o /tmp/pjecalc-temp.log && mv /tmp/pjecalc-temp.log /tmp/pjecalc.log


sed -i "s/^==========.*/$INICIO/g" "$log"


# ----------------------------------------------------------------------------------------


exit 0
