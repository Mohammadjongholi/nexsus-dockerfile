FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    tigervnc-standalone-server \
    dbus \
    dbus-x11 \
    xauth \
    sudo \
    wget \
    curl \
    net-tools \
    procps \
    wine64 \
    wine32 \
    winbind \
    && rm -rf /var/lib/apt/lists/*

# Create GUI user
RUN useradd -m -s /bin/bash guiuser && \
    echo "guiuser:guiuser" | chpasswd && \
    usermod -aG sudo guiuser

# Application installer
COPY 7z2602.exe /home/guiuser/7z2602.exe

# VNC startup script
COPY start-vnc.sh /usr/local/bin/start-vnc.sh

RUN chmod +x /usr/local/bin/start-vnc.sh && \
    chown guiuser:guiuser /usr/local/bin/start-vnc.sh && \
    chown guiuser:guiuser /home/guiuser/7z2602.exe

USER guiuser
WORKDIR /home/guiuser

EXPOSE 5901

ENTRYPOINT ["/usr/local/bin/start-vnc.sh"]
