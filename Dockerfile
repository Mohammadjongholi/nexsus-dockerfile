FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/*

# Create GUI user
RUN useradd -m -s /bin/bash guiuser && \
    echo "guiuser:guiuser" | chpasswd && \
    usermod -aG sudo guiuser

COPY start-vnc.sh /usr/local/bin/start-vnc.sh

RUN chmod +x /usr/local/bin/start-vnc.sh && \
    chown guiuser:guiuser /usr/local/bin/start-vnc.sh

USER guiuser
WORKDIR /home/guiuser

EXPOSE 5901

ENTRYPOINT ["/usr/local/bin/start-vnc.sh"]
