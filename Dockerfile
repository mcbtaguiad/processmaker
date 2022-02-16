# Base Image
FROM centos:7
#FROM amazonlinux:latest
CMD ["/bin/bash"]

# Extra
LABEL version="3.5.7"
LABEL description="ProcessMaker 3.5.7 Docker Container - Apache & PHP 7.3"

# Initial steps
#RUN yum clean all && yum install epel-release -y && yum update -y
#RUN amazon-linux-extras install epel -y
#RUN amazon-linux-extras enable php7.3

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm


RUN yum install yum-utils -y
RUN yum-config-manager --enable remi-php73
RUN yum -y install php php-cli php-opcache php-fpm php-gd php-mysqlnd php-soap php-mbstring php-ldap php-mcrypt php-xml php-imap
RUN cp /etc/hosts ~/hosts.new && sed -i "/127.0.0.1/c\127.0.0.1 localhost localhost.localdomain `hostname`" ~/hosts.new && cp -f ~/hosts.new /etc/hosts



RUN yum -y install wget nano vim gcc sendmail tar php httpd httpd-tools mod_ssl supervisor python3 cronie mysql


RUN yum -y clean all 

COPY php.ini /etc/
COPY processmaker.conf /etc/php-fpm.d/
COPY laravel-worker-workflow.ini /etc/supervisord.d/
#COPY supervisord.conf /etc/supervisor/

# Download processmaker-3.5.7-community
RUN wget -O "/tmp/processmaker-3.5.7-community.tar.gz" \
      "https://sourceforge.net/projects/processmaker/files/ProcessMaker/3.5.7/processmaker-3.5.7-community.tar.gz/download" \
      --no-check-certificate

#COPY processmaker-3.5.7-community.tar.gz /tmp


# Copy configuration files
COPY pmos.conf /etc/httpd/conf.d
RUN mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bk
COPY httpd.conf /etc/httpd/conf


#COPY ca.crt /etc/pki/tls/certs/ 
#COPY ssl/server.key /etc/pki/tls/private/
#COPY ssl/server.cert /etc/pki/tls/certs/



COPY systemctl3.py /usr/bin/systemctl
COPY journalctl3.py /usr/bin/journalctl
RUN chmod a+x /usr/bin/systemctl
RUN chmod a+x /usr/bin/journalctl

#Apache Ports
EXPOSE 80 443 

# Docker entrypoint
COPY docker-entrypoint.sh /bin/
RUN chmod a+x /bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
