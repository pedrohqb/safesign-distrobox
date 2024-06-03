#!/bin/bash

# Diretório temporário para armazenar os pacotes .deb
downloads_dir="$HOME/Downloads/debs-certificado"

# Função para instalar distrobox e podman conforme a distribuição
install_distrobox_podman() {
    distro=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
    case $distro in
        fedora)
            sudo dnf install -y distrobox podman
            ;;
        arch)
            sudo pacman -Suy --noconfirm distrobox podman
            ;;
        '"endeavouros"')
            sudo pacman -Suy --noconfirm distrobox podman
            ;;
        '"opensuse-tumbleweed"')
            sudo zypper in -y distrobox podman
            ;;
        debian)
            sudo apt install -y distrobox podman
            ;;
        *)
            echo "Distribuição não suportada."
            exit 1
            ;;
    esac
}

# Função para instalar pcsclite conforme a distribuição
install_pcsclite() {
    distro=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
    case $distro in
        fedora)
            sudo dnf install -y pcsc-lite pcsc-lite-ccid
            sudo systemctl enable --now pcscd.service
            ;;
        arch)
            sudo pacman -Suy --noconfirm pcsclite ccid
            sudo systemctl enable --now pcscd.service
            ;;
        '"endeavouros"')
            sudo pacman -Suy --noconfirm pcsclite ccid
            sudo systemctl enable --now pcscd.service
            ;;
        '"opensuse-tumbleweed"')
            sudo zypper in -y pcsclite pcsc-ccid
            sudo systemctl enable --now pcscd.service
            ;;
        debian)
            sudo apt install -y pcscd
            sudo systemctl enable --now pcscd.service
            ;;
        *)
            echo "Distribuição não suportada."
            exit 1
            ;;
    esac
}

# Função para baixar os pacotes .deb necessários
download_deb_packages() {
    echo "Baixando os pacotes .deb necessários para $downloads_dir..."
    mkdir -p "$downloads_dir"
    cd "$downloads_dir" || exit
    wget -q -nc https://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1n-0+deb11u5_amd64.deb
    wget -q -nc http://ftp.us.debian.org/debian/pool/main/t/tiff/libtiff5_4.2.0-1+deb11u5_amd64.deb
    wget -q -nc http://ftp.us.debian.org/debian/pool/main/libw/libwebp/libwebp6_0.6.1-2.1+deb11u2_amd64.deb
    wget -q -nc http://ftp.us.debian.org/debian/pool/main/w/wxwidgets3.0/libwxbase3.0-0v5_3.0.5.1+dfsg-2_amd64.deb
    wget -q -nc http://ftp.debian.org/debian/pool/main/w/wxwidgets3.0/libwxgtk3.0-gtk3-0v5_3.0.5.1+dfsg-2_amd64.deb
    wget -q -nc https://certificaat.kpn.com/files/drivers/SafeSign/SafeSign\ IC\ Standard\ Linux\ 4.0.0.0-AET.000\ ub2004\ x86_64.deb
}

# Função para remover o diretório de pacotes .deb após a instalação
remove_deb_dir() {
    echo "Removendo o diretório de pacotes .deb..."
    rm -rf "$downloads_dir"
}

# Instalação do distrobox e podman
install_distrobox_podman

# Instalação do pcsclite
install_pcsclite

# Baixar os pacotes .deb necessários
download_deb_packages

# Criar e entrar no contêiner
distrobox-create --image debian:stable --name certificado -Y

# Instalar aplicações no contêiner e exportar
distrobox-enter certificado -- sudo apt install -y firefox-esr nano 
distrobox-enter certificado -- sudo apt install -y "$downloads_dir"/*.deb
distrobox-enter certificado -- distrobox-export --app tokenadmin 
distrobox-enter certificado -- distrobox-export --app firefox-esr

# Configurações finais
echo "Lembre-se de carregar o certificado digital no Firefox no gerenciador de dispositivos."
echo "Para configurar o certificado no WebPKI, instale o plugin no Firefox e sinalize a opção 'Dispositivos SafeSign AET' em 'Cripto Dispositivos'."
echo "Para o PjeOffice Pro, edite o pjeoffice-pro.sh e altere 'a3auto=true' para 'a3auto=false'. Em seguida, habilite-o como executável e exporte-o."
echo "Verifique as instruções fornecidas no tutorial para mais detalhes."

# Remover o diretório de pacotes .deb após a instalação
remove_deb_dir
