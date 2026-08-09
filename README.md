# Nexus Repository + Wine + XFCE + VNC

A Docker/Podman image based on **Ubuntu 24.04** that runs **Sonatype Nexus Repository**, **Wine**, an **XFCE graphical desktop**, and **TigerVNC**.

This setup is designed for environments where a Windows `.exe` application needs to run inside a Linux container and be accessed through a graphical VNC session.

## Features

* Ubuntu 24.04
* Sonatype Nexus Repository 3.95.0-07
* OpenJDK 17
* Wine
* Wine32 / Wine64
* XFCE Desktop
* TigerVNC
* Persistent Nexus data
* Persistent Wine environment
* Docker Compose / Podman Compose
* Windows `.exe` application support
* GUI access through VNC

## Architecture

                    ┌─────────────────────────────┐
                    │       Windows Client        │
                    │                             │
                    │     VNC Viewer              │
                    └──────────────┬──────────────┘
                                   │
                                   │ TCP 5901
                                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    Ubuntu 24.04 Container                   │
│                                                             │
│  ┌──────────────────┐       ┌────────────────────────────┐  │
│  │   TigerVNC       │──────▶│       XFCE Desktop         │  │
│  │   Port 5901      │       │                            │  │
│  └──────────────────┘       │  ┌──────────────────────┐  │  │
│                             │  │        Wine          │  │  │
│                             │  │                      │  │  │
│                             │  │    Windows .exe      │  │  │
│                             │  └──────────────────────┘  │  │
│                             └────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                 Nexus Repository                      │  │
│  │                     Port 8081                         │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
             │                              │
             ▼                              ▼
      nexus-data volume              wine-data volume
```

## Project Structure

```text
nexus-wine/
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── install-app.sh
├── apps/
│   └── application.exe
└── README.md
```

## Requirements

### Linux Server

The image can be built and run with:

* Podman
* Podman Compose

Docker users can also use:

* Docker
* Docker Compose

### Client

For graphical access, install a VNC client on your workstation.

Examples:

* TigerVNC Viewer
* RealVNC Viewer
* Remmina

## Build the Image

Build the image with Podman:

podman build -t nexus-wine:3.95.0-07 .
```

Or with Compose:

podman compose build
```

## Start the Container

Start the container in detached mode:

podman compose up -d
```

Check the running container:

podman ps
```

Check the container logs:

podman logs -f nexus-wine
```

## Ports

| Port | Service | Description                    |
| ---: | ------- | ------------------------------ |
| 8081 | Nexus   | Nexus Repository Web Interface |
| 5901 | VNC     | XFCE graphical desktop         |

## Access Nexus

Open the following address from your browser:

```text
http://SERVER_IP:8081
```

Example:

```text
http://172.18.115.50:8081
```

## Access the GUI with VNC

Connect your VNC client to:

```text
SERVER_IP:5901
```

Example:

```text
172.18.115.50:5901
```

The default password configured in `docker-compose.yml` is:

```text
ChangeMe123!
```

**Change this password before using the environment in production.**

## Run Windows Applications

Windows `.exe` applications can be executed through Wine.

For example:

```bash
wine /apps/application.exe
```

You can also launch the application from the XFCE graphical desktop through the VNC session.

## Copy an EXE into the Container

Copy an application into the running container:

```bash
podman cp application.exe nexus-wine:/apps/application.exe
```

Enter the container:

```bash
podman exec -it nexus-wine bash
```

Run the application:

```bash
wine /apps/application.exe
```

## Mount Applications from the Host

Instead of copying applications into the container, you can mount an application directory.

Example:

```yaml
volumes:
  - ./apps:/apps
  - nexus-data:/nexus-data
  - wine-data:/wine
```

Host directory:

```text
apps/
├── application1.exe
├── application2.exe
└── application3.exe
```

Inside the container:

```text
/apps/application1.exe
/apps/application2.exe
/apps/application3.exe
```

This allows `.exe` applications to be updated without rebuilding the Docker image.

## Persistent Storage

The container uses named volumes for persistent data.

### Nexus Data

```text
nexus-data:/nexus-data
```

Nexus stores its application and repository data under:

```text
/nexus-data
```

### Wine Data

```text
wine-data:/wine
```

Wine stores its environment under:

```text
/wine
```

List volumes:

```bash
podman volume ls
```

Inspect the Nexus volume:

```bash
podman volume inspect nexus-wine_nexus-data
```

Inspect the Wine volume:

```bash
podman volume inspect nexus-wine_wine-data
```

## Check Nexus Status

Check the container:

```bash
podman ps
```

Check Nexus logs:

```bash
podman logs nexus-wine
```

Follow the logs:

```bash
podman logs -f nexus-wine
```

Check whether Nexus is listening on port 8081:

```bash
podman exec nexus-wine ss -lntp
```

## Check VNC

Check whether VNC is listening:

```bash
podman exec nexus-wine ss -lntp | grep 5901
```

Expected:

```text
LISTEN 0  ... 0.0.0.0:5901
```

## Enter the Container

Open a shell:

```bash
podman exec -it nexus-wine bash
```

Check Wine:

```bash
wine --version
```

Check Java:

```bash
java -version
```

Check Nexus:

```bash
/opt/nexus/bin/nexus status
```

## Stop the Container

```bash
podman compose down
```

The named volumes will remain intact.

Start again:

```bash
podman compose up -d
```

Your Nexus and Wine data will remain available.

## Remove the Container and Volumes

**Warning:** This permanently removes the persistent Nexus and Wine data.

```bash
podman compose down -v
```

Do not use this command if you need to preserve your Nexus repositories or Wine environment.

## Installation Prompts

Linux package installation is configured to run non-interactively.

The Dockerfile uses:

```dockerfile
ENV DEBIAN_FRONTEND=noninteractive
```

and:

```bash
apt-get install -y
```

Therefore, you normally do not need to manually type:

```text
Y
```

during the Docker image build.

Windows `.exe` installers are different. Wine applications may display graphical installation dialogs. These can be handled through the VNC desktop.

## Security

For production environments:

1. Change the VNC password.
2. Do not expose port `5901` directly to the public internet.
3. Restrict VNC access using your firewall.
4. Use a VPN or private management network for VNC.
5. Use HTTPS/reverse proxy for Nexus when required.
6. Use strong credentials for Nexus.
7. Regularly back up the `nexus-data` volume.

Example firewall concept:

```text
Internet
   │
   X  TCP 5901
   │
Private Network
   │
   └── VNC Client
```

## Technology Stack

| Technology       | Version / Purpose                 |
| ---------------- | --------------------------------- |
| Ubuntu           | 24.04                             |
| Nexus Repository | 3.95.0-07                         |
| Java             | OpenJDK 17                        |
| Wine             | Windows application compatibility |
| XFCE             | Linux graphical desktop           |
| TigerVNC         | Remote graphical access           |
| Podman           | Container runtime                 |
| Docker Compose   | Container orchestration           |

## Useful Commands

### Build

```bash
podman compose build
```

### Start

```bash
podman compose up -d
```

### Stop

```bash
podman compose down
```

### Restart

```bash
podman compose restart
```

### Status

```bash
podman ps
```

### Logs

```bash
podman logs -f nexus-wine
```

### Shell

```bash
podman exec -it nexus-wine bash
```

### Volumes

```bash
podman volume ls
```

## Repository

**Official GitHub Repository**

```text
https://github.com/Mohammadjongholi/nexsus-dockerfile
```

## License

This project is provided for infrastructure, testing, and educational purposes.

Nexus Repository, Ubuntu, Wine, XFCE, and TigerVNC are separate projects and are subject to their respective licenses and terms.

```
```

