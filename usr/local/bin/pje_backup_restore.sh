#!/bin/bash
#
# Autor: Fernando Souza - https://www.youtube.com/@fernandosuporte/
# Modificado por Pedro Henrique Quitete Barreto - pedrohqb@gmail.com
# Homepage: https://github.com/pedrohqb/pjecalc-instalador
# Licença:  MIT

# Caminhos base

PASTA_ORIGEM="$HOME/PjeCalc/.dados"
PASTA_DESTINO="$HOME/PjeCalc"
DATA_HORA=$(date +"%Y-%m-%d_%H-%M")
ARQUIVO_BACKUP="$HOME/PjeCalc-dados-$DATA_HORA.tar.gz"
LOGFILE="$HOME/PjeCalc-backup.log"
MAX_BACKUPS=7


# Função de log com data/hora

log() {

    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"

}


# Verificação de dependências

verificar_dependencias() {
    if ! command -v tar >/dev/null 2>&1; then
        log "❌ ERRO: O comando 'tar' não está instalado."
        exit 1
    fi
    if ! tar --help | grep -q gzip; then
        log "❌ ERRO: O comando 'tar' não tem suporte a gzip."
        exit 1
    fi
}


# Função para limpar backups antigos

limpar_backups_antigos() {
    BACKUPS=( $(ls -1t "$HOME"/PjeCalc-dados-*.tar.gz 2>/dev/null) )
    TOTAL=${#BACKUPS[@]}
    if (( TOTAL > MAX_BACKUPS )); then
        log "🧹 Limpando backups antigos (mantendo os $MAX_BACKUPS mais recentes)..."
        for (( i=MAX_BACKUPS; i<TOTAL; i++ )); do
            rm -f "${BACKUPS[$i]}"
            log "🗑️ Apagado: ${BACKUPS[$i]}"
        done
    fi
}


# Função de backup

fazer_backup() {
    if [ -d "$PASTA_ORIGEM" ]; then
        log "📦 Iniciando backup da pasta $PASTA_ORIGEM..."
        tar -czf "$ARQUIVO_BACKUP" -C "$PASTA_DESTINO" .dados
        log "✅ Backup concluído: $ARQUIVO_BACKUP"

        echo "" >> "$LOGFILE"

        limpar_backups_antigos


        ls -lh $HOME/PjeCalc-dados-*.tar.gz

    else
        log "❌ ERRO: A pasta $PASTA_ORIGEM não existe."
    fi
}


# Função de restauração

restaurar_backup() {
    ARQUIVO_MAIS_RECENTE=$(ls -t "$HOME"/PjeCalc-dados-*.tar.gz 2>/dev/null | head -n 1)
    if [ -f "$ARQUIVO_MAIS_RECENTE" ]; then
        log "♻️ Restaurando backup de: $ARQUIVO_MAIS_RECENTE..."
        rm -rf "$PASTA_ORIGEM"
        tar -xzvf "$ARQUIVO_MAIS_RECENTE" -C "$PASTA_DESTINO"
        log "✅ Restauração concluída!"
    else
        log "❌ ERRO: Nenhum arquivo de backup encontrado em $HOME."
    fi
}


# Execução principal

verificar_dependencias

case "$1" in
    backup)
        fazer_backup
        ;;
    restaurar)
        restaurar_backup
        ;;
    *)
        echo "Uso: $0 {backup|restaurar}"
        exit 1
        ;;
esac


exit 0
