FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && echo "America/New_York" > /etc/timezone

# We removed VNC/Websockify and installed XRDP instead. Kept all your tools!
RUN dpkg --add-architecture i386 && apt update -y && \
    apt install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    xrdp \
    sudo wget curl firefox dbus-x11 x11-xserver-utils nano vim git net-tools && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Create Admin User
RUN useradd -m -s /bin/bash admin && \
    echo "admin:7388" | chpasswd && \
    echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Tell XRDP to boot XFCE when you log in
RUN echo "startxfce4" > /home/admin/.xsession && \
    chown admin:admin /home/admin/.xsession && \
    adduser xrdp ssl-cert

# Keep standard RDP port
EXPOSE 3389

# Start XRDP Manager
CMD mkdir -p /var/run/xrdp && /usr/sbin/xrdp-sesman & /usr/sbin/xrdp -nodaemon
