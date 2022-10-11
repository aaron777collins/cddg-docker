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
  qt4-dev-tools \
  libfox-1.6-dev

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

RUN apt-get -yy install locales && locale-gen en_US.UTF-8

# Fun tools
RUN apt-get -yy install htop net-tools \
xfce4-terminal \
gnome-terminal \
firefox \
git \
nano \
terminator

RUN wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg \
&& echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list && apt-get update && apt-get -yy install sublime-text

WORKDIR /home/ubuntu
RUN mkdir -p /repos
WORKDIR /home/ubuntu/repos
RUN git clone https://github.com/aaron777collins/ConnectedDrivingDataGenerator.git

# RUN chmod +x /usr/bin/start.sh

RUN apt-get -y install locales software-properties-common

RUN touch /usr/share/locale/locale.alias

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN gsettings set org.gnome.desktop.default-applications.terminal exec /usr/bin/terminator && gsettings set org.gnome.desktop.default-applications.terminal exec-arg "-x"

# VOLUME ["/etc/ssh","/home"]
EXPOSE 3389 22 9001 3350
# ENTRYPOINT ["/usr/bin/docker-entrypoint.sh", "/bin/bash", "/usr/bin/start.sh"]
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["supervisord"]

RUN rm /var/run/xrdp/xrdp-sesman.pid

# RUN update-alternatives --config x-terminal-emulator

RUN add-apt-repository ppa:sumo/stable && apt-get update && apt-get -yy install sumo sumo-tools sumo-doc

WORKDIR /home/ubuntu/repos
RUN wget -O omnetpp-5.7.tgz https://github.com/omnetpp/omnetpp/releases/download/omnetpp-5.7/omnetpp-5.7-linux-x86_64.tgz
RUN tar --extract --file omnetpp-5.7.tgz
WORKDIR /home/ubuntu/repos/omnetpp-5.7
RUN apt-get -yy install qt5-default openscenegraph
RUN apt-add-repository universe && apt-get update && apt-get -yy install libopenscenegraph-dev
RUN apt-get -yy install libgeos-dev libosgearth-dev libopenmpi-dev
ENV QT_SELECT=5
RUN ["/bin/bash", "-c", "source ./setenv && export QT_SELECT=5 && ./configure && make"]
