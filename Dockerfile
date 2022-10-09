FROM ubuntu:18.04

ADD bin /usr/bin

RUN apt-get update -yy && apt-get upgrade -yy

# Docker config
VOLUME ["/etc/ssh","/home"]

RUN apt install -yy \
  openssh-server
# RUN ufw allow ssh

RUN mkdir /var/run/xrdp
RUN mkdir /var/run/xrdp-sesman

RUN apt update && apt -y upgrade
ARG DEBIAN_FRONTEND=noninteractive
RUN apt install -y xfce4
RUN apt-get install -yy xrdp
RUN cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
# RUN sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini
RUN sed -i 's/max_bpp=32/#max_bpp=32\nmax_bpp=128/g' /etc/xrdp/xrdp.ini
RUN sed -i 's/xserverbpp=24/#xserverbpp=24\nxserverbpp=128/g' /etc/xrdp/xrdp.ini
RUN /etc/init.d/xrdp start

#Install new parts
RUN apt install -yy \
  build-essential \
  gcc \
  g++ \
  bison \
  flex \
  perl \
  tcl-dev \
  tk-dev \
  blt \
  libxml2-dev \
  zlib1g-dev \
  default-jre \
  doxygen \
  graphviz \
  libwebkitgtk-1.0-0 \
  openmpi-bin \
  libopenmpi-dev \
  libpcap-dev \
  autoconf \
  automake \
  libtool \
  libproj-dev \
  libgdal-dev \
  libxerces-c-dev \
  qt4-dev-tools

ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir /var/run/sshd

RUN apt-get install -yy supervisor

# ADD etc/supervisor /etc/supervisor
COPY etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD etc/supervisor/conf.d /etc/supervisor/conf.d

# ARG DEBIAN_FRONTEND=noninteractive
# RUN adduser ubuntu
# RUN usermod -aG sudo ubuntu

COPY etc/users.list /etc/users.list

RUN apt-get update && apt-get -y install sudo
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

RUN usermod -aG sudo ubuntu
RUN adduser xrdp ssl-cert

RUN mkdir -p /home/ubuntu

# Fun tools
RUN apt-get -yy install htop net-tools \
# xfce4-terminal \
x-terminal-emulator \
firefox \
git

WORKDIR /home/ubuntu
RUN mkdir -p /repos
WORKDIR /home/ubuntu/repos
RUN git clone https://github.com/aaron777collins/ConnectedDrivingDataGenerator.git

# VOLUME ["/etc/ssh","/home"]
EXPOSE 3389 22 9001 3350
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["supervisord"]

RUN rm /var/run/xrdp/xrdp-sesman.pid

RUN update-alternatives --config x-terminal-emulator
