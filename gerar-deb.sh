#!/bin/bash

# Variáveis baseadas no seu PKGBUILD
PKGNAME="pjecalc-instalador"
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

# 2. Criar o arquivo DEBIAN/control
cat << EOF > "$BUILD_DIR/DEBIAN/control"
Package: $PKGNAME
Version: $PKGVER-$PKGREL
Section: utils
Priority: optional
Architecture: $ARCH
Depends: zulu-8, p7zip, kdialog
Maintainer: $MAINTAINER
Description: $DESCRIPTION
EOF

# 3. Organizar arquivos (Equivalente à função package() do PKGBUILD)
echo "Organizando arquivos..."
INTERNAL_DIR="src_git"

# Verifica se existe a subpasta com o mesmo nome (lógica do seu PKGBUILD)
if [ -d "src_git/$PKGNAME" ]; then
    INTERNAL_DIR="src_git/$PKGNAME"
fi

# Copia as pastas usr, etc, opt se existirem
for dir in usr etc opt; do
    if [ -d "$INTERNAL_DIR/$dir" ]; then
        mkdir -p "$BUILD_DIR/$dir"
        cp -r "$INTERNAL_DIR/$dir/." "$BUILD_DIR/$dir/"
    fi
done

# 4. Construir o pacote .deb
echo "Gerando pacote .deb..."
dpkg-deb --build "$BUILD_DIR" "${PKGNAME}_${PKGVER}-${PKGREL}_${ARCH}.deb"

# Limpeza
# rm -rf "$BUILD_DIR" src_git
echo "Concluído!"
