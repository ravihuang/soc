FROM centos:centos7
MAINTAINER Jan Garaj info@monitoringartist.com

# ZABBIX_VERSION=trunk tags/2.4.7 branches/dev/ZBXNEXT-1263-1

ENV \
  ZABBIX_VERSION=trunk \
  ZS_enabled=true \
  ZA_enabled=true \
  ZW_enabled=true \
  SNMPTRAP_enabled=false \
  STATUS_PAGE_ALLOWED_IP=127.0.0.1 \
  JAVA_HOME=/usr/lib/jvm/jre \
  JAVA=/usr/bin/java \
  PHP_date_timezone=UTC \
  PHP_max_execution_time=300 \
  PHP_max_input_time=300 \
  PHP_memory_limit=128M \
  PHP_error_reporting=E_ALL \
  ZS_ListenPort=10051 \
  ZS_SourceIP="" \
  ZS_LogFile=/tmp/soc_server.log \
  ZS_LogFileSize=10 \
  ZS_DebugLevel=3 \
  ZS_PidFile=/var/run/soc_server.pid \
  ZS_DBHost=soc.db \
  ZS_DBName=soc \
  ZS_DBSchema="" \
  ZS_DBUser=soc \
  ZS_DBPassword=soc \
  ZS_DBSocket=/tmp/mysql.sock \
  ZS_DBPort=3306 \
  ZS_StartPollers=5 \
  ZS_StartPollersUnreachable=1 \
  ZS_StartTrappers=5 \
  ZS_StartPingers=1 \
  ZS_StartDiscoverers=1 \
  ZS_StartHTTPPollers=1 \
  ZS_StartTimers=1 \
  ZS_JavaGateway=127.0.0.1 \
  ZS_JavaGatewayPort=10052 \
  ZS_StartJavaPollers=0 \
  ZS_StartVMwareCollectors=0 \
  ZS_VMwareFrequency=60 \
  ZS_VMwarePerfFrequency=60 \
  ZS_VMwareCacheSize=8M \
  ZS_VMwareTimeout=10 \
  ZS_SNMPTrapperFile=/tmp/soc_traps.tmp \
  ZS_StartSNMPTrapper=0 \
  ZS_ListenIP=0.0.0.0 \
  ZS_HousekeepingFrequency=1 \
  ZS_MaxHousekeeperDelete=500 \
  ZS_SenderFrequency=30 \
  ZS_CacheSize=8M \
  ZS_CacheUpdateFrequency=60 \
  ZS_StartDBSyncers=4 \
  ZS_HistoryCacheSize=8M \
  ZS_TrendCacheSize=4M \
  ZS_HistoryTextCacheSize=16M \
  ZS_ValueCacheSize=8M \
  ZS_Timeout=3 \
  ZS_TrapperTimeout=300 \
  ZS_UnreachablePeriod=45 \
  ZS_UnavailableDelay=60 \
  ZS_UnreachableDelay=15 \
  ZS_AlertScriptsPath=/usr/local/share/soc/alertscripts \
  ZS_ExternalScripts=/usr/local/share/soc/externalscripts \
  ZS_FpingLocation=/usr/sbin/fping \
  ZS_Fping6Location=/usr/sbin/fping6 \
  ZS_SSHKeyLocation="" \
  ZS_LogSlowQueries=0 \
  ZS_TmpDir=/tmp \
  ZS_StartProxyPollers=1 \
  ZS_ProxyConfigFrequency=3600 \
  ZS_ProxyDataFrequency=1 \
  ZS_AllowRoot=0 \
  ZS_User=soc \
  ZS_Include="" \
  ZS_SSLCertLocation=/usr/local/share/soc/ssl/certs \
  ZS_SSLKeyLocation=/usr/local/share/soc/ssl/keys \
  ZS_SSLCALocation="" \
  ZS_LoadModulePath=/usr/lib/soc/modules \
  ZS_LoadModule="" \
  ZS_TLSCAFile="" \
  ZS_TLSCRLFile="" \
  ZS_TLSCertFile="" \
  ZS_TLSKeyFile="" \
  ZW_ZBX_SERVER=localhost \
  ZW_ZBX_SERVER_PORT=10051 \
  ZW_ZBX_SERVER_NAME="Security Operation Center" \
  ZA_PidFile=/tmp/soc_agentd.pid \
  ZA_LogType=console \
  ZA_LogFile=/tmp/soc_agentd.log \
  ZA_LogFileSize=1 \
  ZA_DebugLevel=3 \
  ZA_SourceIP="" \
  ZA_EnableRemoteCommands=0 \
  ZA_LogRemoteCommands=0 \
  ZA_Server=127.0.0.1 \
  ZA_ListenPort=10050 \
  ZA_ListenIP=0.0.0.0 \
  ZA_StartAgents=3 \
  ZA_ServerActive=127.0.0.1 \
  ZA_Hostname="SOC" \
  ZA_HostnameItem= \
  ZA_HostMetadata="" \
  ZA_HostMetadataItem="" \
  ZA_RefreshActiveChecks=120 \
  ZA_BufferSend=5 \
  ZA_BufferSize=100 \
  ZA_MaxLinesPerSecond=20 \
  ZA_Timeout=3 \
  ZA_AllowRoot=0 \
  ZA_User=soc \
  ZA_Include="" \
  ZA_UnsafeUserParameters=0 \
  ZA_UserParameter="" \
  ZA_LoadModulePath="" \
  ZA_LoadModule="" \
  ZA_TLSConnect=unencrypted \
  ZA_TLSAccept=unencrypted \
  ZA_TLSCAFile="" \
  ZA_TLSCRLFile="" \
  ZA_TLSServerCertIssuer="" \
  ZA_TLSServerCertSubject="" \
  ZA_TLSCertFile="" \
  ZA_TLSKeyFile="" \
  ZA_TLSPSKIdentity="" \
  ZA_TLSPSKFile="" \
  TERM=xterm

# Layer: base
RUN \
  yum clean all && \
  yum update -y && \
  yum install -y epel-release && \
  sed -i -e "\|^https://\"http://|d" /etc/yum.repos.d/epel.repo && \
  yum clean all && \
  yum install -y supervisor && \
  yum install -y http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && \
  yum install -y nginx inotify-tools && \
  `# Rename nginx:nginx user/group to www:www, also set uid:gid to 80:80 (just to make it nice)` \
  groupmod --gid 80 --new-name www nginx && \
  usermod --uid 80 --home /data/www --gid 80 --login www --shell /bin/bash --comment www nginx && \
  `# Clean-up /etc/nginx/ directory from all not needed stuff...` \
  rm -rf /etc/nginx/*.d /etc/nginx/*_params && \
  `# Prepare dummy SSL certificates` \
  mkdir -p /etc/nginx/ssl && \
  openssl genrsa -out /etc/nginx/ssl/dummy.key 2048 && \
  openssl req -new -key /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.csr -subj "/C=GB/L=ShenZhen/O=Greaty/CN=soc-docker" && \
  openssl x509 -req -days 3650 -in /etc/nginx/ssl/dummy.csr -signkey /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.crt && \
  yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum install -y --enablerepo=remi-php56 php-fpm \
       php-gd php-bcmath php-ctype php-xml php-xmlreader php-xmlwriter \
       php-session php-net-socket php-mbstring php-gettext php-cli \
       php-mysqlnd php-opcache php-pdo php-snmp php-ldap php-mcrypt && \
  yum clean all && rm -rf /tmp/*
ADD container-files-base /

# Layer: soc
COPY container-files-soc /
RUN \
  yum clean all && \
  yum update -y && \
  yum install -y tar svn gcc automake make nmap traceroute iptstate wget \
              net-snmp-devel net-snmp-libs net-snmp net-snmp-perl iksemel \
              net-snmp-python net-snmp-utils java-1.8.0-openjdk python-pip \
              java-1.8.0-openjdk-devel mariadb-devel libxml2-devel gettext \
              libcurl-devel OpenIPMI-devel mysql iksemel-devel libssh2-devel \
              unixODBC unixODBC-devel mysql-connector-odbc postgresql-odbc \
              openldap-devel telnet net-tools snmptt sudo rubygems && \
 `# reinstall glibc for locales` \
  yum -y -q reinstall glibc-common && \
  gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/ && \
  gem install sass && \  
  wget https://github.com/schweikert/fping/archive/3.10.tar.gz && \
  tar -xvf 3.10.tar.gz && \
  cd fping-3.10/ && \
  ./autogen.sh && \
  ./configure --prefix=/usr --enable-ipv6 --enable-ipv4 && \
  make && \
  make install && \
  setcap cap_net_raw+ep /usr/sbin/fping || echo 'Warning: setcap cap_net_raw+ep /usr/sbin/fping' && \
  setcap cap_net_raw+ep /usr/sbin/fping6 || echo 'Warning: setcap cap_net_raw+ep /usr/sbin/fping6' && \
  chmod 4710 /usr/sbin/fping && \
  chmod 4710 /usr/sbin/fping6 && \
  cd .. && \
  rm -rf fping-3.10 && \
  rm -rf 3.10.tar.gz && \
  pip install py-zabbix

#GREATY_VERSION
ENV SOC_VERSION=160129.1
RUN  cp /usr/local/etc/soc_agentd.conf /tmp && \
  svn co http://172.16.5.114/svn/zabbix /usr/local/src/soc && \
  cd /usr/local/src/soc && \
  ls && \
  DATE=`date +%Y-%m-%d` && \
  sed -i "s/ZABBIX_VERSION.*'\(.*\)'/ZABBIX_VERSION', '\1 ($DATE)'/g" frontends/php/include/defines.inc.php && \
  sed -i "s/ZABBIX_VERSION_RC.*\"\(.*\)\"/ZABBIX_VERSION_RC \"\1 (${DATE})\"/g" include/version.h && \
  sed -i "s/String VERSION =.*\"\(.*\)\"/String VERSION = \"\1 (${DATE})\"/g" src/zabbix_java/src/com/zabbix/gateway/GeneralInformation.java && \
  ./bootstrap.sh && \
  ./configure --enable-server --enable-agent --with-mysql --enable-java \
              --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi \
              --enable-ipv6 --with-jabber --with-openssl --with-ssh2 \
              --with-ldap --with-unixodbc && \
  make dbschema && \
  make css && \
  make install && \
  cp -f /tmp/soc_agentd.conf /usr/local/etc/ && \
  cd /usr/local/src/soc/frontends/php && \
  locale/make_mo.sh && \
  `yum autoremove -y gettext python-pip tar gcc automake mariadb-devel java-1.8.0-openjdk-devel libxml2-devel libcurl-devel OpenIPMI-devel iksemel-devel rubygems kernel-headers && ` \
  yum install -y OpenIPMI-libs && \
  chmod +x /config/bootstrap.sh && \
  chmod +x /config/ds.sh && \
  chmod +x /usr/local/src/soc/misc/snmptrap/soc_trap_receiver.pl && \
  chmod +x /usr/share/snmptt/snmptthandler-embedded && \
  sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && \
  yum clean all && \
  mkdir -p /usr/local/share/ssl/certs && \
  mkdir -p /usr/local/share/ssl/keys && \
  mkdir -p /usr/lib/soc/modules && \
  mkdir -p /etc/soc/snmp/mibs && \
  rm -rf /usr/local/src/soc/[a,A,b,c,C,i,I,m,M,n,N,r,R,s,t,u,r,\.]* /usr/local/src/soc/depcomp /usr/local/src/soc/.svn && \
  rm -rf /usr/local/src/soc/database/[i,M,o,p,s]* && \
  rm -rf /tmp/*

  # TODO apply http://geofrogger.net/review/snmptt-hide-generic-part.patch

CMD ["/usr/sbin/init"]

VOLUME ["/etc/custom-config", "/usr/local/share/soc/externalscripts", "/usr/local/share/soc/ssl/certs", "/usr/local/share/soc/ssl/keys", "/usr/lib/soc/modules", "/usr/share/snmp/mibs", "/etc/snmp"]

EXPOSE 80 162/udp 10051 10052
