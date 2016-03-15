FROM centos:7

RUN yum -y update && yum -y groupinstall core && yum -y groupinstall base && yum -y install epel-release
RUN yum -y install automake gcc gcc-c++ ncurses-devel openssl-devel libxml2-devel unixODBC-devel \
  libcurl-devel libogg-devel libvorbis-devel speex-devel spandsp-devel freetds-devel net-snmp-devel \
  iksemel-devel corosynclib-devel newt-devel popt-devel libtool-ltdl-devel lua-devel sqlite-devel \
  radiusclient-ng-devel portaudio-devel neon-devel libical-devel openldap-devel gmime-devel mysql-devel \
  bluez-libs-devel jack-audio-connection-kit-devel gsm-devel libedit-devel libuuid-devel jansson-devel \
  libsrtp-devel git subversion libxslt-devel kernel-devel audiofile-devel gtk2-devel libtiff-devel \
  libtermcap-devel ilbc-devel bison php php-mysql php-process php-pear php-mbstring php-xml php-gd \
  tftp-server httpd sox tzdata mysql-connector-odbc mariadb mariadb-server fail2ban jwhois
RUN pear install Console_getopt
RUN sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
RUN cd /usr/src && wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz
RUN cd /usr/src && wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-2.10.2+2.10.2.tar.gz
RUN cd /usr/src && wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-1.4-current.tar.gz
RUN cd /usr/src && wget http://www.pjsip.org/release/2.4.5/pjproject-2.4.5.tar.bz2
RUN cd /usr/src && tar xvf asterisk-13-*
RUN cd /usr/src && tar xvf dahdi-linux-complete-*
RUN cd /usr/src && tar xvf libpri-*
RUN cd /usr/src && tar xvf pjproject-*
RUN cd /usr/src/dahdi-linux-complete-* && make all && make install && make config
RUN cd /usr/src/libpri-1.4.* && make && make install
RUN cd /usr/src/pjproject-* && ./configure --prefix=/usr --libdir=/usr/lib64 --enable-shared --disable-sound --disable-resample \
  --disable-video --disable-opencore-amr CFLAGS='-O2 -DNDEBUG' && make dep && make && make install && ldconfig
RUN cd /usr/src/asterisk-13.* && make distclean && ./configure --libdir=/usr/lib64 && make menuselect.makeopts && menuselect/menuselect --enable cdr_mysql --enable EXTRA-SOUNDS-EN-GSM menuselect.makeopts
RUN adduser asterisk -s /sbin/nologin -c "Asterisk User"
RUN cd /usr/src/asterisk-13.* && make && make install && chown -R asterisk. /var/lib/asterisk
RUN cd /usr/src && git clone -b release/13.0 https://github.com/FreePBX/framework.git freepbx
