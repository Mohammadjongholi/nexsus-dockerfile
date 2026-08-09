# ============================================================
# Nexus + Wine + XFCE + VNC
# Ubuntu 24.04
# ============================================================

FROM ubuntu:24.04

ARG NEXUS_VERSION=3.95.0-07

ENV DEBIAN_FRONTEND=noninteractive
ENV NEXUS_HOME=/opt/nexus
ENV NEXUS_DATA=/nexus-data
ENV WINEPREFIX=/wine
ENV DISPLAY=:1

# ============================================================
# System packages
# ============================================================

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        unzip \
        procps \
        net-tools \
        openjdk-17-jdk \
        wine \
        wine64 \
        wine32 \
        winbind \
        xvfb \
        xfce4 \
        xfce4-goodies \
        tigervnc-standalone-server \
        tigervnc-tools \
        dbus-x11 \
        xterm \
        sudo && \
    rm -rf /var/lib/apt/lists/*

# ============================================================
# Nexus
# ============================================================

RUN wget -q \
    "https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-linux-x86_64.tar.gz" \
    -O /tmp/nexus.tar.gz && \
    mkdir -p /opt && \
    tar -xzf /tmp/nexus.tar.gz -C /opt && \
    mv "/opt/nexus-${NEXUS_VERSION}" "${NEXUS_HOME}" && \
    rm -f /tmp/nexus.tar.gz

# ============================================================
# Nexus user
# ============================================================

RUN useradd \
        --system \
        --create-home \
        --home-dir /home/nexus \
        --shell /bin/bash \
        nexus && \
    mkdir -p \
        "${NEXUS_DATA}" \
        "${WINEPREFIX}" \
        /home/nexus/.vnc && \
    chown -R nexus:nexus \
        "${NEXUS_HOME}" \
        "${NEXUS_DATA}" \
        "${WINEPREFIX}" \
        /home/nexus

# Nexus configuration

RUN echo 'run_as_user="nexus"' > "${NEXUS_HOME}/bin/nexus.rc"

# ============================================================
# Java
# ============================================================

ENV INSTALL4J_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# ============================================================
# Wine
# ============================================================

ENV WINEPREFIX=/wine

# Initialize Wine during build
RUN su - nexus -c "wineboot --init" || true

# ============================================================
# VNC configuration
# ============================================================

RUN mkdir -p /home/nexus/.vnc && \
    chown -R nexus:nexus /home/nexus/.vnc

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY install-app.sh /usr/local/bin/install-app.sh

RUN chmod +x \
    /usr/local/bin/entrypoint.sh \
    /usr/local/bin/install-app.sh && \
    chown nexus:nexus \
        /usr/local/bin/entrypoint.sh \
        /usr/local/bin/install-app.sh

# ============================================================
# Ports
# ============================================================

# Nexus
EXPOSE 8081

# VNC
EXPOSE 5901

# ============================================================
# Runtime
# ============================================================

USER nexus

WORKDIR /home/nexus

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

