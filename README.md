
Uma das maiores dificuldades que se tem é garantir a compatibilidade das distribuições Linux com os pacotes que fornecem certificados digitais. O empacotamento por vezes pode ser compatível – como o caso do deb fornecido pela Safesign para Ubuntu quando instalado no Debian -, mas por vezes não o é – como no caso do rpm fornecido pela Safesign para RHEL no openSUSE.

Hoje em dia isso pode ser facilmente ultrapassado mediante o uso do distrobox em conjunto com podman.

O presente script tem por objetivo fazer com que isso seja feito de maneira automatizada no Fedora, Arch, openSUSE e Debian, bem como em qualquer distribuição derivada.

Àqueles que testaram em outras distros, peço, por gentileza, que informem o conteúdo do /etc/os-release, bem como as alterações efetuadas no script.
