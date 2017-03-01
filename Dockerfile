FROM centos:6.8

MAINTAINER Bruno Bertechini "bruno.bertechini@outlook.com"

#	
# UPDATE PACKAGES
#
RUN yum update -y

#
# Add Epel Mirror
#
RUN yum install -y epel-release

#
# TOOLS
#
RUN yum install -y curl wget unzip yum-utils python-setuptools ImageMagick ImageMagick-devel mlocate nmap vim git vsftpd

## CLEAN UP
RUN package-cleanup --dupes
RUN package-cleanup --cleandupes
RUN yum clean all

#
# CWP - Centos Web Panel
#
WORKDIR /usr/local/src
RUN wget http://centos-webpanel.com/cwp-latest
RUN sed -i -e "/^shutdown/c\ " cwp-latest
RUN sed -i -e "/^read -p/c\ " cwp-latest
RUN sh cwp-latest

#
# Install PHP Composer
#
WORKDIR /tmp
RUN curl -sS https://getcomposer.org/installer | php
RUN mv /tmp/composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

#
# Compile Tesseract
#
RUN yum install -y gcc gcc-c++ make autoconf automake libtool libjpeg-devel libpng-devel libtiff-devel zlib-devel
RUN mkdir -p /usr/src/tesseract
COPY leptonica-1.71.tar.gz /usr/src/tesseract/
COPY tesseract-3.04.01.tar.gz /usr/src/tesseract/
RUN tar zxvf /usr/src/tesseract/leptonica-1.71.tar.gz -C /usr/src/tesseract/
RUN tar zxvf /usr/src/tesseract/tesseract-3.04.01.tar.gz -C /usr/src/tesseract/

WORKDIR /usr/src/tesseract/leptonica-1.71
RUN pwd
RUN ls
RUN ./configure
RUN make
RUN make install

WORKDIR /usr/src/tesseract/tesseract-3.04.01
RUN pwd
RUN ls
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install
RUN ldconfig

WORKDIR /usr/src/tesseract
RUN pwd
RUN ls
RUN git clone https://github.com/tesseract-ocr/tessdata.git
WORKDIR /usr/src/tesseract/tessdata
RUN cp *.traineddata /usr/local/share/tessdata/

WORKDIR /

#
# FTP
#
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf

#
# SUPERVISOR
#
RUN easy_install supervisor
RUN mkdir -p /etc/supervisor/conf.d
RUN /usr/bin/echo_supervisord_conf > /etc/supervisor/supervisord.conf
RUN sed -i -e "s/^nodaemon=false/nodaemon=true/" /etc/supervisor/supervisord.conf
ADD supervisor/ /etc/supervisor/conf.d/
RUN echo "[include]" >> /etc/supervisor/supervisord.conf
RUN echo "files=/etc/supervisor/conf.d/*.conf" >> /etc/supervisor/supervisord.conf

EXPOSE 80 2030 3306 21 20 4242 4243

#
# Start Supervisor in foreground
#
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]