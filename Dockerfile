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
RUN yum install -y curl wget unzip yum-utils python-setuptools

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

WORKDIR /

EXPOSE 2030