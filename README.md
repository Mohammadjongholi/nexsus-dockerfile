# Ubuntu 24.04 + XFCE + Wine + TigerVNC

A containerized **Ubuntu 24.04 graphical desktop environment** with **XFCE**, **TigerVNC**, and **Wine**.

This project is designed to run Windows `.exe` applications inside an Ubuntu container and provide access to the graphical desktop remotely through a VNC client.

The container includes both **Wine 64-bit and 32-bit support**, making it suitable for testing and running many Windows applications that require a graphical environment.

---

## Features

* Ubuntu 24.04
* XFCE Desktop
* XFCE Terminal
* TigerVNC Server
* Wine 64-bit
* Wine 32-bit
* Winbind
* DBus
* Persistent GUI user home directory
* VNC remote graphical access
* Windows `.exe` application support
* Docker Compose support
* Podman Compose compatible
* Runs as a non-root user

---

## Architecture

```text
                         VNC Client
                    ┌──────────────────┐
                    │ TigerVNC Viewer  │
                    │ RealVNC / Remmina│
                    └────────┬─────────┘
                             │
                          TCP 5901
                             │
                             ▼
┌───────────────────────────────────────────────────────┐
│                 Ubuntu 24.04 Container                │
│                                                       │
│  ┌─────────────────────────────────────────────────┐  │
│  │                 TigerVNC                        │  │
│  │                  :5901                           │  │
│  └───────────────────────┬─────────────────────────┘  │
│                          │                            │
│                          ▼                            │
│  ┌─────────────────────────────────────────────────┐  │
│  │                    XFCE                         │  │
│  │                                                 │  │
│  │  ┌───────────────────────────────────────────┐  │  │
│  │  │                    Wine                   │  │  │
│  │  │                                           │  │  │
│  │  │              7z2602.exe                   │  │  │
│  │  │              Other EXE files              │  │  │
│  │  └───────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────┘  │
│                                                       │
│                    guiuser                             │
│                                                       │
└───────────────────────────┬───────────────────────────┘
                            │
                            ▼
                    Persistent Volume
                       gui_home
                    /home/guiuser
```

---

# Project Structure

```text
ubuntu-gui/
├── Dockerfile
├── docker-compose.yml
├── start-vnc.sh
├── 7z2602.exe
└── README.md
```

### Files

| File                 | Description                                             |
| -------------------- | ------------------------------------------------------- |
| `Dockerfile`         | Builds the Ubuntu 24.04 GUI image                       |
| `docker-compose.yml` | Defines the container, port, volume, and restart policy |
| `start-vnc.sh`       | Starts the VNC server and XFCE desktop                  |
| `7z2602.exe`         | Windows application used for Wine testing               |
| `README.md`          | Project documentation                                   |

---

# Requirements

## Server

The project can be run using:

* Docker
* Docker Compose
* Podman
* Podman Compose

Check Podman:

```bash
podman --version
```

Check Compose:

```bash
podman compose version
```

For Docker:

```bash
docker --version
docker compose version
```

---

# Build the Image

## Podman

From the project directory:

```bash
cd ~/mohammad/ubuntu
```

Build the image:

```bash
podman compose build
```

Or build directly:

```bash
podman build -t ubuntu-gui .
```

## Docker

```bash
docker compose build
```

Or:

```bash
docker build -t ubuntu-gui .
```

---

# Start the Container

## Podman

```bash
podman compose up -d
```

## Docker

```bash
docker compose up -d
```

Check the container:

```bash
podman ps
```

Expected container:

```text
ubuntu-gui
```

---

# Container Configuration

The Compose file creates:

```text
Container name: ubuntu-gui
VNC port:       5901
User:           guiuser
Home directory: /home/guiuser
Volume:         gui_home
```

The VNC port is published as:

```text
5901:5901
```

This means the host's TCP port `5901` is forwarded to the container's TCP port `5901`.

---

# Access the XFCE Desktop

Install a VNC client on your workstation.

Examples:

* TigerVNC Viewer
* RealVNC Viewer
* Remmina

Connect to:

```text
SERVER_IP:5901
```

For example:

```text
172.18.115.50:5901
```

---

# VNC Credentials

The Dockerfile creates the user:

```text
guiuser
```

The initial Linux password configured by the Dockerfile is:

```text
guiuser
```

**Change the password before using this container in a production environment.**

The relevant Dockerfile configuration is:

```dockerfile
RUN useradd -m -s /bin/bash guiuser && \
    echo "guiuser:guiuser" | chpasswd && \
    usermod -aG sudo guiuser
```

---

# Run Windows Applications with Wine

The image contains:

```text
wine64
wine32
winbind
```

Check Wine:

```bash
podman exec -it ubuntu-gui wine --version
```

You can also enter the container:

```bash
podman exec -it ubuntu-gui bash
```

Then:

```bash
wine --version
```

---

# 7-Zip Application

The project currently copies:

```text
7z2602.exe
```

into:

```text
/home/guiuser/7z2602.exe
```

The file is copied by the Dockerfile:

```dockerfile
COPY 7z2602.exe /home/guiuser/7z2602.exe
```

Because the container runs as `guiuser`, the application belongs to that user.

Inside the container:

```bash
ls -lh /home/guiuser/7z2602.exe
```

Run it with:

```bash
wine /home/guiuser/7z2602.exe
```

You can also launch it from the XFCE graphical desktop.

---

# Installing Other Windows Applications

You can copy another `.exe` file into the container.

For example:

```bash
podman cp application.exe ubuntu-gui:/home/guiuser/application.exe
```

Enter the container:

```bash
podman exec -it ubuntu-gui bash
```

Run it:

```bash
wine /home/guiuser/application.exe
```

Alternatively, applications can be placed in the project directory and copied into the image through the Dockerfile.

---

# Persistent Home Directory

The Compose file defines:

```yaml
volumes:
  - gui_home:/home/guiuser
```

This creates a persistent volume:

```text
gui_home
```

mounted at:

```text
/home/guiuser
```

This means files stored in the user's home directory can survive container recreation.

List volumes:

```bash
podman volume ls
```

Inspect the volume:

```bash
podman volume inspect ubuntu_gui_gui_home
```

The exact volume name may vary depending on the Compose project name.

---

# Important Note About the Persistent Volume

The Dockerfile copies `7z2602.exe` into:

```text
/home/guiuser/7z2602.exe
```

However, the Compose volume:

```yaml
- gui_home:/home/guiuser
```

is mounted **over the entire `/home/guiuser` directory** when the container starts.

Therefore, if the volume already exists, files created in the image under `/home/guiuser` may be hidden by the mounted volume.

If `7z2602.exe` is not visible after starting the container, check:

```bash
podman exec -it ubuntu-gui ls -lah /home/guiuser
```

For a more reliable design, application files can be stored outside the mounted home directory, for example:

```text
/apps/7z2602.exe
```

or mounted from the host.

---

# Check Container Status

```bash
podman ps
```

For all containers:

```bash
podman ps -a
```

---

# Check Logs

View logs:

```bash
podman logs ubuntu-gui
```

Follow logs:

```bash
podman logs -f ubuntu-gui
```

The logs are particularly useful for troubleshooting TigerVNC and XFCE startup problems.

---

# Check VNC Port

Inside the container:

```bash
podman exec ubuntu-gui ss -lntp | grep 5901
```

If `ss` is unavailable:

```bash
podman exec ubuntu-gui netstat -lntp | grep 5901
```

On the host:

```bash
ss -lntp | grep 5901
```

Expected host-side result should show port `5901` listening.

---

# Check XFCE

Enter the container:

```bash
podman exec -it ubuntu-gui bash
```

Check the XFCE installation:

```bash
which startxfce4
```

Expected:

```text
/usr/bin/startxfce4
```

---

# Check TigerVNC

Inside the container:

```bash
which vncserver
```

Check the installed version:

```bash
vncserver --version
```

Check running VNC processes:

```bash
ps aux | grep -i vnc
```

---

# Enter the Container

Open a shell:

```bash
podman exec -it ubuntu-gui bash
```

Check the current user:

```bash
whoami
```

Expected:

```text
guiuser
```

Check the home directory:

```bash
echo $HOME
```

Expected:

```text
/home/guiuser
```

Check Ubuntu:

```bash
cat /etc/os-release
```

Check Wine:

```bash
wine --version
```

---

# Stop the Container

Stop the environment:

```bash
podman compose down
```

Or:

```bash
docker compose down
```

The persistent `gui_home` volume is not removed.

---

# Restart the Container

```bash
podman compose restart
```

Or:

```bash
docker compose restart
```

---

# Start Again

```bash
podman compose up -d
```

Check:

```bash
podman ps
```

---

# Remove the Container and Volume

To remove the container and persistent volume:

```bash
podman compose down -v
```

**Warning:** This removes the `gui_home` volume and can permanently delete data stored in `/home/guiuser`.

Do not use `-v` if you want to preserve the user's home directory.

---

# Firewall

If the server uses `firewalld`, allow TCP port `5901` if remote VNC access is required:

```bash
firewall-cmd --permanent --add-port=5901/tcp
firewall-cmd --reload
```

Verify:

```bash
firewall-cmd --list-ports
```

For production environments, do **not** expose VNC directly to the public Internet.

Restrict access to trusted networks or use a VPN/SSH tunnel.

---

# Security

This project is primarily intended for testing, development, and controlled infrastructure environments.

Before production use:

1. Change the `guiuser` password.
2. Change the VNC password configured by `start-vnc.sh`.
3. Do not expose TCP `5901` to the public Internet.
4. Restrict VNC access using firewall rules.
5. Prefer VPN or SSH tunneling for remote VNC access.
6. Avoid storing credentials in Git.
7. Review the applications being executed through Wine.
8. Keep the Ubuntu packages updated.
9. Rebuild the image periodically to receive security updates.

---

# Troubleshooting

## Container does not start

Check:

```bash
podman ps -a
```

Then:

```bash
podman logs ubuntu-gui
```

---

## VNC connection fails

Check:

```bash
podman exec ubuntu-gui ss -lntp | grep 5901
```

Check the host:

```bash
ss -lntp | grep 5901
```

Check the container logs:

```bash
podman logs ubuntu-gui
```

Check the VNC startup script:

```bash
podman exec ubuntu-gui cat /usr/local/bin/start-vnc.sh
```

---

## XFCE does not start

Check:

```bash
podman logs ubuntu-gui
```

Then enter the container:

```bash
podman exec -it ubuntu-gui bash
```

Check:

```bash
which startxfce4
```

---

## Wine does not start

Check:

```bash
podman exec -it ubuntu-gui wine --version
```

Check Wine binaries:

```bash
which wine
which wine64
which wine32
```

Check whether the application exists:

```bash
podman exec ubuntu-gui ls -lah /home/guiuser/
```

---

## 7-Zip EXE is missing

Check:

```bash
podman exec ubuntu-gui ls -lah /home/guiuser/7z2602.exe
```

Remember that the Compose volume:

```yaml
- gui_home:/home/guiuser
```

mounts over the image's `/home/guiuser` directory.

If necessary, copy the application into the running container:

```bash
podman cp 7z2602.exe ubuntu-gui:/home/guiuser/7z2602.exe
```

Then:

```bash
podman exec ubuntu-gui ls -lh /home/guiuser/7z2602.exe
```

---

# Useful Commands

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

### All containers

```bash
podman ps -a
```

### Logs

```bash
podman logs -f ubuntu-gui
```

### Shell

```bash
podman exec -it ubuntu-gui bash
```

### Check VNC

```bash
podman exec ubuntu-gui ss -lntp | grep 5901
```

### Check Wine

```bash
podman exec ubuntu-gui wine --version
```

### Copy EXE

```bash
podman cp application.exe ubuntu-gui:/home/guiuser/application.exe
```

### List volumes

```bash
podman volume ls
```

---

# Technology Stack

| Technology | Version / Purpose                  |
| ---------- | ---------------------------------- |
| Ubuntu     | 24.04                              |
| XFCE       | Desktop environment                |
| TigerVNC   | VNC server                         |
| Wine       | Windows application compatibility  |
| Wine64     | 64-bit Windows application support |
| Wine32     | 32-bit Windows application support |
| Winbind    | Windows compatibility support      |
| DBus       | Desktop session support            |
| Podman     | Container runtime                  |
| Docker     | Alternative container runtime      |
| Compose    | Container orchestration            |

---

# Repository

GitHub repository:

```text
https://github.com/Mohammadjongholi/nexsus-dockerfile
```

---

# License

This project is provided for infrastructure, testing, and educational purposes.

Ubuntu, XFCE, TigerVNC, Wine, and other included software are separate projects and are subject to their respective licenses and terms.

