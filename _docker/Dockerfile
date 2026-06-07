############################################################################################################
# Build Instructions
############################################################################################################
FROM php:8.4-fpm-bookworm
ENV DEBIAN_FRONTEND=noninteractive

##
## Install Updates
##
RUN apt update -y && apt upgrade -y && apt-get clean

##
## Install Dependencies
##
RUN apt install apache2 software-properties-common nano git sl gcc make autoconf pkg-config imagemagick openssl redis curl cron tzdata zip htop unzip tmux redis-server redis-tools wget iputils-ping apache2-suexec-custom jq libc-dev libonig-dev libpng-dev zlib1g-dev libcurl4-openssl-dev libicu-dev libxml2-dev libzip-dev libsodium-dev libmemcached-dev libssl-dev libtidy-dev libkrb5-dev libssh2-1-dev libgd-dev libc-client-dev libbz2-dev jq libmagickwand-dev libldap2-dev libfreetype6-dev libjpeg-dev sshpass gzip tar python3 python3-pip python3-venv perl libwebp-dev mariadb-client mariadb-server certbot supervisor -y \
	&& python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir \
    numpy pathlib pandas requests urllib3 scipy matplotlib seaborn \
    scikit-learn botocore boto3 openai pillow jupyter flask fastapi \
    django sqlalchemy pytest black setuptools \
    && apt-get update \
    && apt-get install -y cpanminus \
    && cpanm --notest DBI DBD::SQLite LWP::UserAgent JSON YAML \
    DateTime Try::Tiny Moose List::MoreUtils Scalar::List::Utils \
	&& a2enmod ssl && a2enmod rewrite && a2enmod headers && a2enmod cgi && a2enmod cgid && a2enmod remoteip && a2enmod deflate && a2enmod http2 && a2enmod proxy \
	&& a2enmod proxy_http && a2enmod proxy_ftp && a2enmod proxy_fcgi setenvif && a2enmod proxy_balancer && a2enmod suexec && a2dismod mpm_prefork && a2enmod mpm_event \
    && rm -rf /root/.cpanm /var/lib/apt/lists/* /opt/venv/bin/cache/* 

##
## PHP Mod Setup and Fixes
##
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && git clone https://github.com/Imagick/imagick --depth 1 /tmp/imagick \
    && cd /tmp/imagick \
    && phpize \
    && ./configure CPPFLAGS='-Dphp_strtolower=zend_str_tolower' \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -rf /tmp/imagick

##
## Install PHP Extensions
## Some extensions are pre installed in php, they are commented out.
##
RUN docker-php-ext-install mysqli && docker-php-ext-install xml && docker-php-ext-install mbstring && docker-php-ext-install curl && docker-php-ext-install zip && docker-php-ext-install ctype && docker-php-ext-install filter && docker-php-ext-install intl && docker-php-ext-install fileinfo && docker-php-ext-configure gd --with-freetype --with-jpeg  --with-webp && docker-php-ext-install gd && docker-php-ext-install bcmath && docker-php-ext-install soap && docker-php-ext-install pdo && docker-php-ext-install exif && docker-php-ext-install dom && docker-php-ext-install bz2 && docker-php-ext-install sockets && docker-php-ext-install tidy && pecl install imap && docker-php-ext-enable imap && pecl install ssh2 && docker-php-ext-enable ssh2 && pecl install memcached && docker-php-ext-enable memcached && pecl install redis && docker-php-ext-enable redis && docker-php-ext-enable imagick && docker-php-ext-enable sodium && docker-php-ext-install ldap && docker-php-ext-install simplexml


##
## Set Timezone
##
ENV TZ=${sf_timezone}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo "$TZ" > /etc/timezone

##
## Install MySQL Configuration
##
RUN echo "[mysqld]\n\
skip-networking=0\n\
bind-address=0.0.0.0" > /etc/mysql/mariadb.conf.d/99-custom.cnf

##
## Supervisor Configuration
##
RUN mkdir -p /var/log/supervisor /var/run /etc/supervisor/conf.d \
    && echo "[unix_http_server]\n\
file=/var/run/supervisor.sock\n\
chmod=0700\n\
chown=root:root\n\
\n\
[supervisord]\n\
logfile=/var/log/supervisor/supervisord.log\n\
logfile_maxbytes=50MB\n\
logfile_backups=10\n\
loglevel=info\n\
pidfile=/var/run/supervisord.pid\n\
nodaemon=true\n\
minfds=1024\n\
minprocs=200\n\
user=root\n\
childlogdir=/var/log/supervisor\n\
strip_ansi_escapes=true\n\
environment=ENV=\"production\"\n\
\n\
[supervisorctl]\n\
serverurl=unix:///var/run/supervisor.sock\n\
\n\
[include]\n\
files = /etc/supervisor/conf.d/*.conf" > /etc/supervisor/supervisord.conf

##
## Install Supervisor Scripts
##
COPY ./_supervisor/supervisor_cron.conf /etc/supervisor/conf.d/supervisor_cron.conf
COPY ./_supervisor/supervisor_apache2.conf /etc/supervisor/conf.d/supervisor_apache2.conf
COPY ./_supervisor/supervisor_mysql.conf /etc/supervisor/conf.d/supervisor_mysql.conf
COPY ./_supervisor/supervisor_php_fpm.conf /etc/supervisor/conf.d/supervisor_php_fpm.conf
COPY ./_supervisor/supervisor_redis.conf /etc/supervisor/conf.d/supervisor_redis.conf

##
## Apache Copy Sites
##
COPY _vsites/ /etc/apache2/sites-available/

##
## Apache Copy Configuration
##
COPY _vhost/ /etc/apache2/conf-available/

##
## Apache Copy Website Content
##
RUN rm -rf /var/www/html/*
COPY _public/ /var/www/html/

##
## Create Folder for Apache Certificate
##
RUN mkdir -p /opt/sf_ssl

##
## Apache Enable Websites
##
RUN a2ensite 000-default && a2ensite default-ssl

##
## Copy Scripts and Cleanup Image
##
COPY ./_script/entrypoint.sh /entrypoint.sh
COPY ./_script/restart_mysql.sh /restart_mysql.sh
RUN chmod u+x /entrypoint.sh && chmod u+x /restart_mysql.sh && apt-get clean && rm -rf /var/lib/apt/lists/*

##
## Add Entrypoint
##
ENTRYPOINT ["/entrypoint.sh"]

##
## Startup Instructions
##
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf", "--silent"]