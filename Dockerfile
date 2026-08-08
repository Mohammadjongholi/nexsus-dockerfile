FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# ==================================================
# Java + Wine + utilities
# ==================================================

RUN apt-get update && \
    apt-get install -y \
        openjdk-17-jdk \
        wget \
        curl \
        unzip \
        ca-certificates \
        wine64 \
        winbind \
        && \
    rm -rf /var/lib/apt/lists/*

# ==================================================
# Nexus Repository
# ==================================================

ENV NEXUS_VERSION=3.95.0-07
ENV NEXUS_HOME=/opt/nexus
ENV NEXUS_DATA=/nexus-data

RUN wget -q \
    https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-linux-x86_64.tar.gz \
    -O /tmp/nexus.tar.gz && \
    mkdir -p /opt && \
    tar -xzf /tmp/nexus.tar.gz -C /opt && \
    mv /opt/nexus-${NEXUS_VERSION} ${NEXUS_HOME} && \
    rm -f /tmp/nexus.tar.gz

# ==================================================
# Nexus user
# ==================================================

RUN useradd -r -m -d /home/nexus nexus && \
    mkdir -p ${NEXUS_DATA} /wine && \
    chown -R nexus:nexus ${NEXUS_HOME} ${NEXUS_DATA} /wine

RUN echo 'run_as_user="nexus"' > ${NEXUS_HOME}/bin/nexus.rc

# ==================================================
# Java
# ==================================================

ENV INSTALL4J_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# ==================================================
# Wine
# ==================================================

ENV WINEPREFIX=/wine

# ==================================================
# Nexus
# ==================================================

EXPOSE 8081

CMD ["/opt/nexus/bin/nexus", "run"]
