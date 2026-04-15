FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=steam
ENV HOME=/home/steam
ENV STEAMCMDDIR=/opt/steamcmd
ENV DISPLAY=:99
ENV WINEDEBUG=-all
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN dpkg --add-architecture i386 && \
  apt update
RUN apt install -y \
  curl wget ca-certificates \
  xvfb xauth \
  winbind \
  locales gpg
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings
RUN wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key
RUN wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
RUN apt update
RUN apt install -y --install-recommends \
  winehq-stable

RUN sed -i 's/^# \(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen && locale-gen

RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

RUN useradd -u 1000 -m -s /bin/bash steam

RUN mkdir -p /opt/steamcmd && \
  curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    | tar -xz -C /opt/steamcmd && \
  chown -R steam:steam /opt/steamcmd /home/steam

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER steam
WORKDIR /home/steam

ENTRYPOINT ["/entrypoint.sh"]
