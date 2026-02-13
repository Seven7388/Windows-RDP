FROM ubuntu:22.04

# ============================================
# SILENCE ALL INTERACTIVE PROMPTS
# ============================================
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    echo "America/New_York" > /etc/timezone

# ============================================
# INSTALL DESKTOP & VNC PACKAGES
# ============================================
RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    sudo \
    wget \
    curl \
    firefox \
    dbus-x11 \
    x11-xserver-utils \
    nano \
    vim \
    git \
    net-tools \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# CREATE ADMIN USER
# ============================================
RUN useradd -m -s /bin/bash admin && \
    echo "admin:7388" | chpasswd && \
    echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ============================================
# SET UP VNC PASSWORD AND STARTUP SCRIPT
# ============================================
RUN mkdir -p /home/admin/.vnc && \
    echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > /home/admin/.vnc/xstartup && \
    chmod +x /home/admin/.vnc/xstartup && \
    echo "7388" | vncpasswd -f > /home/admin/.vnc/passwd && \
    chmod 600 /home/admin/.vnc/passwd && \
    chown -R admin:admin /home/admin/.vnc

# ============================================
# ✅ FIX XWRAPPER (CREATE FILE IF MISSING)
# ============================================
RUN mkdir -p /etc/X11 && \
    touch /etc/X11/Xwrapper.config && \
    echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

# ============================================
# EXPOSE PORTS (VNC + NOVNC WEB)
# ============================================
EXPOSE 5901 8080

# ============================================
# START VNC AND NOVNC WITH 1920x1080 RESOLUTION
# ============================================
CMD su - admin -c "vncserver :1 -geometry 1920x1080 -depth 24 -localhost no && websockify -D --web=/usr/share/novnc/ 8080 localhost:5901 && tail -f /dev/null"
