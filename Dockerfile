# Usamos Ubuntu 22.04 LTS (La versión más estable y común actualmente para CTFs)
# Puedes cambiarla a 24.04 en el futuro si los retos empiezan a usar libcs más nuevas.
FROM ubuntu:22.04

# Variables de entorno para evitar prompts durante la instalación
# y configurar el idioma a UTF-8 (Vital para pwntools y gdb)
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_CTYPE=C.UTF-8

# 1. Instalar dependencias del sistema y herramientas esenciales
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    vim \
    nano \
    tmux \
    gdb \
    gdb-multiarch \
    python3 \
    python3-pip \
    python3-dev \
    strace \
    ltrace \
    file \
    netcat \
    socat \
    elfutils \
    patchelf \
    ruby \
    ruby-dev \
    libssl-dev \
    libffi-dev \
    bsdmainutils \
    libc6-dbg \
    glibc-source \
    qemu-user \
    qemu-user-static \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    libc6-arm64-cross \
    libc6-armhf-cross \
    && rm -rf /var/lib/apt/lists/*

RUN cd /usr/src/glibc && tar -xvf glibc-*.tar.xz || true
# 2. Instalar herramientas de Python (Pwntools, Ropper, ROPgadget)
# Usamos --no-cache-dir para que la imagen pese menos
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir pwntools ropper ROPgadget

# 3. Instalar herramientas de Ruby (one_gadget, seccomp-tools)
# Imprescindibles para retos de pwn y escapes de sandbox
RUN gem install one_gadget seccomp-tools

# 4. Instalar Pwndbg (Plugin de GDB)
# Clona el repositorio y ejecuta su script de instalación automático
RUN git clone https://github.com/pwndbg/pwndbg /opt/pwndbg && \
    cd /opt/pwndbg && \
    ./setup.sh

# 5. Instalar pwninit
# Descarga el binario precompilado y le da permisos de ejecución
RUN wget -O /usr/local/bin/pwninit https://github.com/io12/pwninit/releases/download/3.3.0/pwninit && \
    chmod +x /usr/local/bin/pwninit

RUN echo "[context]\nterminal=['tmux', 'splitw', '-h']" > /root/.pwn.conf && \
    echo "set-option -g mouse on\nset -g default-terminal \"xterm-256color\"" > /root/.tmux.conf

# 6. Directorio de trabajo
# Al mapear el volumen desde Rust, todo caerá en esta carpeta
WORKDIR /ctf

# 7. Comando por defecto
# Esto mantiene el contenedor "vivo" indefinidamente en segundo plano 
# para que puedas entrar (attach), salir, y volver a entrar sin que se apague.
CMD
