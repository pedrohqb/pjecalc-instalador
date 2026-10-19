# pjecalc-instalador

Instalador não oficial do **PJe-Calc Cidadão** para Debian, Ubuntu, Linux Mint e demais distribuições derivadas do Debian (64 bits).

Oficialmente, o PJe-Calc Cidadão só tem instalador para Windows. Mas ele é um programa em Java e funciona no Linux. Este pacote extrai o programa de dentro do instalador `.exe` oficial e o executa com o Java do sistema (Azul Zulu 8), **sem precisar do Wine**.

Depois de instalado, o pacote acrescenta dois itens ao menu de aplicativos, na categoria **Escritório**:

- **Instalar ou remover o PjeCalc**: instala, atualiza ou remove o PJe-Calc a partir do `.exe` oficial; e
- **PjeCalc**: abre o programa no navegador.

## Requisitos

- Debian, Ubuntu, Linux Mint ou derivado, em **64 bits (amd64)**.
- **Azul Zulu 8 (JDK), no pacote `.deb` baixado do site da Azul.** O instalador depende do pacote `zulu-8` e procura o Java em `/usr/lib/jvm/zulu-8-amd64`.
- No **Debian**, o repositório `contrib` habilitado. No **Ubuntu**, o repositório `multiverse`. Neles está o pacote das fontes da Microsoft (`ttf-mscorefonts-installer`), de que o PJe-Calc precisa para exibir os relatórios corretamente.

As demais dependências são instaladas automaticamente pelo `apt`: `p7zip-full` (ou `7zip`), `kdialog`, `curl`, `fontconfig` e `ttf-mscorefonts-installer`.

> **Atenção:** o pacote `zulu8-jdk` do repositório APT da Azul **não serve**. Ele tem outro nome e instala o Java em outra pasta (`/usr/lib/jvm/zulu8-ca-amd64`), de modo que o PJe-Calc não o encontra. Use o `.deb` avulso, conforme o passo 1 abaixo.

## Instalação

### 1. Instale o Zulu 8

1. Acesse https://www.azul.com/downloads/?version=java-8-lts&package=jdk#zulu.
2. Filtre por **Java 8 (LTS)**, **Linux**, **x86 64-bit** e **JDK**.
3. Baixe o arquivo **`.deb`** (o nome é parecido com `zulu8.xx.xx-ca-jdk8.0.xxx-linux_amd64.deb`).
4. Na pasta onde o arquivo foi salvo, instale-o:
   ```
   sudo apt install ./zulu8*-linux_amd64.deb
   ```

### 2. Habilite o repositório das fontes da Microsoft

- **Debian**: acrescente `contrib` às linhas do arquivo `/etc/apt/sources.list` (ou, nas versões mais novas, à linha `Components:` de `/etc/apt/sources.list.d/debian.sources`) e rode `sudo apt update`.
- **Ubuntu**: `sudo add-apt-repository multiverse`.
- **Linux Mint**: o repositório já vem habilitado.

Durante a instalação, o `ttf-mscorefonts-installer` pede que você aceite a licença das fontes.

### 3. Instale o pacote pjecalc-instalador

Baixe o `.deb` da versão mais recente na página de [Releases](https://github.com/pedrohqb/pjecalc-instalador/releases) e, na pasta onde ele foi salvo, rode:

```
sudo apt install ./pjecalc-instalador_*_all.deb
```

Se preferir, gere o pacote você mesmo (veja [Como gerar o pacote](#como-gerar-o-pacote)).

## Uso

### Instalar o PJe-Calc

1. Baixe o instalador do **PJe-Calc Cidadão para Windows** (arquivo `.exe`) na [página oficial de download](https://www.trt8.jus.br/pjecalc-cidadao/instalando-o-pje-calc-cidadao). Serve tanto a versão de 32 quanto a de 64 bits.
2. Abra **Instalar ou remover o PjeCalc** no menu de aplicativos.
3. Clique em **Continuar** e selecione o arquivo `.exe` baixado.
4. Aguarde a mensagem de instalação concluída.

O PJe-Calc é instalado na pasta `~/PjeCalc`, dentro da pasta pessoal do usuário. Não apague nem renomeie essa pasta. A instalação vale só para o usuário que a fez: cada usuário do computador tem seu próprio PJe-Calc e seus próprios dados.

### Abrir o PJe-Calc

Abra **PjeCalc** no menu de aplicativos. O programa inicia em segundo plano e, assim que estiver pronto, abre sozinho no navegador padrão, no endereço http://localhost:9257/pjecalc/pages/principal.jsf. A primeira abertura pode levar alguns segundos.

Se o navegador for fechado, basta abrir **PjeCalc** de novo no menu (ou acessar o mesmo endereço): o programa continua rodando.

### Atualizar o PJe-Calc

Quando os tribunais adotarem uma versão nova do PJe-Calc Cidadão:

1. Baixe o `.exe` da nova versão.
2. Abra **Instalar ou remover o PjeCalc** e escolha **Reinstalar ou atualizar o PjeCalc**.
3. Selecione o novo `.exe`.
4. Quando o instalador perguntar sobre a base de dados existente, escolha **MANTER MEUS DADOS**.

Se o PJe-Calc estiver aberto, o instalador o fecha antes de atualizar.

### Cópia de segurança dos cálculos

Os cálculos ficam na pasta oculta `~/PjeCalc/.dados`. Para fazer uma cópia de segurança, copie essa pasta com o PJe-Calc fechado.

### Remover o PJe-Calc

Abra **Instalar ou remover o PjeCalc**, escolha **REMOVER o PjeCalc!** e confirme. **Isso apaga também todos os cálculos salvos.**

Para remover o próprio instalador:

```
sudo apt remove pjecalc-instalador
```

Remover o instalador não apaga a pasta `~/PjeCalc`.

## O que o instalador faz

1. Fecha o PJe-Calc, se estiver aberto.
2. Extrai o conteúdo do `.exe` com o 7-Zip numa pasta temporária (`~/.pjecalc-instalando`).
3. Descarta o Java e o navegador que vêm embutidos no instalador do Windows.
4. Copia o programa para `~/PjeCalc`.
5. Mantém ou substitui a base de dados (`.dados`), conforme a escolha do usuário. Numa primeira instalação, copia a base de dados inicial que vem no `.exe`.
6. Apaga a pasta temporária.

Ao abrir o PJe-Calc, o lançador:

1. inicia o servidor do PJe-Calc com o Java do Zulu 8, usando o fuso horário de Brasília e uma configuração de fontes própria (`/etc/pjecalc-fonts.conf`), que troca as fontes genéricas do Java por Arial, Times New Roman e Courier New;
2. espera o servidor responder em `localhost:9257`; e
3. abre a página inicial do PJe-Calc no navegador padrão.

## Como gerar o pacote

O pacote também pode ser gerado a partir deste repositório:

```
git clone https://github.com/pedrohqb/pjecalc-instalador.git
cd pjecalc-instalador
bash gerar-deb.sh
```

Ao final, o arquivo `pjecalc-instalador_AA.MM.DD-HHMM_all.deb` estará na pasta atual. A versão do pacote é a data e a hora da geração.

## Solução de problemas

- **Mensagens de erro de `FONTCONFIG` no terminal.** Podem ser ignoradas.
- **Erro de dependência `zulu-8` ao instalar o pacote.** O Zulu 8 não está instalado, ou foi instalado pelo repositório APT da Azul (`zulu8-jdk`). Instale o `.deb` avulso, conforme o passo 1.
- **Erro de dependência `ttf-mscorefonts-installer`.** O repositório `contrib` (Debian) ou `multiverse` (Ubuntu) não está habilitado. Veja o passo 2.
- **Mensagem "Java não encontrado".** O Zulu 8 não está instalado na pasta esperada (`/usr/lib/jvm/zulu-8-amd64`). Instale o `.deb` avulso, conforme o passo 1.
- **Mensagem "PjeCalc não abriu".** O servidor do PJe-Calc não respondeu em até 2 minutos. Para ver as mensagens de erro, rode `pjecalc-abrir` no terminal. Confira também se nenhum outro programa está usando a porta 9257.
- **Mensagem "O PjeCalc ainda não está instalado".** Faça a instalação pelo item **Instalar ou remover o PjeCalc**, conforme a seção [Uso](#uso).
- **Relatórios com fontes estranhas ou desalinhadas.** Confira se o pacote `ttf-mscorefonts-installer` foi instalado e concluiu o download das fontes.

## Créditos

Este projeto é um fork do [pjecalc-instalador do BigLinux](https://github.com/biglinux/pjecalc-instalador), criado por Bruno Gonçalves. Esta versão adapta o instalador para Debian, Ubuntu e derivados, com o Java Zulu 8, a configuração de fontes e o script que gera o pacote `.deb`.

O PJe-Calc Cidadão é software da Justiça do Trabalho e não é distribuído por este repositório: o usuário baixa o instalador oficial e o pacote apenas extrai o programa dele.

## Licença

Distribuído sob a licença [GNU General Public License, versão 3](LICENSE) (GPL-3.0), a mesma do projeto original.

Copyright © 2020–2024 Bruno Gonçalves (BigLinux)\
Copyright © 2025–2026 Pedro Henrique Quitete Barreto
