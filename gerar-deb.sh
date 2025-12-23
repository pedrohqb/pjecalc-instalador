#!/bin/bash

PKGNAME="pjecalc-instalador"
APPNAME="pjecalc"
PKGVER=$(date +%y.%m.%d)
PKGREL=$(date +%H%M)
ARCH="all"
MAINTAINER="Pedro Henrique Quitete Barreto <pedrohqb@gmail.com>"
DESCRIPTION="Script que descompacta o .exe do Pjecalc e faz funcionar no Linux sem precisar do Wine"

# Pasta de trabalho
BUILD_DIR="build_pkg"
mkdir -p "$BUILD_DIR/DEBIAN"

# 1. Clonar o código fonte
echo "Clonando repositório..."
git clone https://github.com/pedrohqb/pjecalc-instalador.git src_git

# 2. Criar configuração de fontes
echo "Criando configuração de fontes..."
mkdir -p "$BUILD_DIR/etc"
cat << EOF > "$BUILD_DIR/etc/pjecalc-fonts.conf"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
<include>/etc/fonts/fonts.conf</include>
<match target="pattern">
<test qual="any" name="family"><string>sans-serif</string></test>
<edit name="family" mode="assign" binding="strong"><string>Arial</string></edit>
</match>
<alias binding="strong"><family>Dialog</family><prefer><family>Arial</family></prefer></alias>
<alias binding="strong"><family>Sans</family><prefer><family>Arial</family></prefer></alias>
<alias binding="strong"><family>serif</family><prefer><family>Times New Roman</family></prefer></alias>
<alias binding="strong"><family>monospaced</family><prefer><family>Courier New</family></prefer></alias>
</fontconfig>
EOF

# Garante que não haja espaços no início do arquivo (segurança contra erro XML)
sed -i 's/^\s*//' "$BUILD_DIR/etc/pjecalc-fonts.conf"

# 3. Criar o arquivo DEBIAN/control
cat << EOF > "$BUILD_DIR/DEBIAN/control"
Package: $PKGNAME
Version: $PKGVER-$PKGREL
Section: utils
Priority: optional
Architecture: $ARCH
Depends: zulu-8, p7zip-full | 7zip, kdialog, curl, fontconfig, ttf-mscorefonts-installer
Maintainer: $MAINTAINER
Description: $DESCRIPTION
EOF

# 4. Organizar arquivos (Equivalente à função package() do PKGBUILD)
echo "Organizando arquivos..."
#INTERNAL_DIR="src_git"
INTERNAL_DIR="."

# Copia as pastas usr, etc, opt se existirem
for dir in usr etc opt; do
    if [ -d "$INTERNAL_DIR/$dir" ]; then
        mkdir -p "$BUILD_DIR/$dir"
        cp -r "$INTERNAL_DIR/$dir/." "$BUILD_DIR/$dir/"
    fi
done

# 5. Construir o pacote .deb
echo "Gerando pacote .deb..."
dpkg-deb --build --root-owner-group "$BUILD_DIR" "${PKGNAME}_${PKGVER}-${PKGREL}_${ARCH}.deb"

# 6. Limpando...
rm -rf "$BUILD_DIR"

echo "Concluído!"
