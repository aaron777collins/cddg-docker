FROM danielguerra/ubuntu-xrdp as ubuntu-with-xrdp

RUN apt-get update -yy && apt-get upgrade -yy

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

# Docker config
VOLUME ["/etc/ssh","/home"]
EXPOSE 3389 22 9001
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["supervisord"]
