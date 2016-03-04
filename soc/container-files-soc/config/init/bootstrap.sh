#!/bin/sh

set -eu
export TERM=xterm
# Bash Colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
white=`tput setaf 7`
bold=`tput bold`
reset=`tput sgr0`
separator=$(echo && printf '=%.0s' {1..100} && echo)

# Logging functions
log() {
  if [[ "$@" ]]; then echo "${bold}${green}[LOG `date +'%T'`]${reset} $@";
  else echo; fi
}
warning() {
  echo "${bold}${yellow}[WARNING `date +'%T'`]${reset} ${yellow}$@${reset}";
}
error() {
  echo "${bold}${red}[ERROR `date +'%T'`]${reset} ${red}$@${reset}";
}
create_db() {
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -e "CREATE DATABASE IF NOT EXISTS ${ZS_DBName} CHARACTER SET utf8;"
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -e "GRANT ALL ON ${ZS_DBName}.* TO '${ZS_DBUser}'@'%' identified by '${ZS_DBPassword}';"
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -e "flush privileges;"
}
import_soc_db() {
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -D ${ZS_DBName} < ${ZABBIX_SQL_DIR}/schema.sql
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -D ${ZS_DBName} < ${ZABBIX_SQL_DIR}/images.sql
  mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -D ${ZS_DBName} < ${ZABBIX_SQL_DIR}/data.sql
}
logging() {
  mkdir -p /var/log/soc
  chmod 777 /var/log/soc
  touch /var/log/soc/soc_server.log /var/log/soc/soc_agentd.log
  chmod 777 /var/log/soc/soc_server.log /var/log/soc/soc_agentd.log
}
system_pids() {
  touch /var/run/soc_server.pid /var/run/soc_agentd.pid /var/run/soc_java.pid
  chmod 777 /var/run/soc_server.pid /var/run/soc_agentd.pid /var/run/soc_java.pid
}
fix_permissions() {
  getent group soc || groupadd soc
  getent passwd soc || useradd -g soc -M soc
  chown -R $ZS_User:$ZS_User /usr/local/etc/
  chown -R $ZS_User:$ZS_User /usr/local/src/soc/
  mkdir -p /usr/local/src/soc/frontends/php/conf/
  chmod 777 /usr/local/src/soc/frontends/php/conf/
  chmod u+s /usr/bin/ping
  chown root:$ZS_User /usr/sbin/fping
  chown root:$ZS_User /usr/sbin/fping6
  chmod 4710 /usr/sbin/fping
  chmod 4710 /usr/sbin/fping6
}
update_config() {
  # ^ZS_: /usr/local/etc/soc_server.conf
  for i in $( set -o posix ; set | grep ^ZS_ | grep -v ^ZS_Include | grep -v ^ZS_LoadModule | grep -v ^ZS_SourceIP | grep -v ^ZS_TLS | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#=${reg}\$#=${val}#g" /usr/local/etc/soc_server.conf
    sed -i "s#${reg}#${val}#g" /usr/local/src/soc/frontends/php/conf/soc.conf.php
  done
  if [ "$ZS_SourceIP" != "" ]; then
    echo SourceIP=${ZS_SourceIP} >> /usr/local/etc/soc_server.conf
  fi
  if [ "$ZS_Include" != "" ]; then
    echo Include=${ZS_Include} >> /usr/local/etc/soc_server.conf
  fi
  if [ "$ZS_LoadModule" != "" ]; then
    echo LoadModule=${ZS_LoadModule} >> /usr/local/etc/soc_server.conf
  fi
  if [ "$ZS_TLSCAFile" != "" ]; then
    echo TLSCAFile=${ZS_TLSCAFile} >> /usr/local/etc/soc_server.conf
  fi
  if [ "$ZS_TLSCRLFile" != "" ]; then
    echo TLSCRLFile=${ZS_TLSCRLFile} >> /usr/local/etc/soc_server.conf
  fi
  if [ "$ZS_TLSCertFile" != "" ]; then
    echo TLSCertFile=${ZS_TLSCertFile} >> /usr/local/etc/soc_server.conf
  fi
  if [ "$ZS_TLSCAFile" != "" ]; then
    echo TLSKeyFile=${ZS_TLSKeyFile} >> /usr/local/etc/soc_server.conf
  fi

  # ^ZA_: /usr/local/etc/soc_agentd.conf
  export ZA_Hostname_e=$(echo ${ZA_Hostname} | sed -e 's/ /\\\ /g')
  sed -i "s#ZA_Hostname#${ZA_Hostname_e}#g" /usr/local/etc/soc_agentd.conf
  unset ZA_Hostname_e
  for i in $( set -o posix ; set | grep ^ZA_ | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#=${reg}\$#=${val}#g" /usr/local/etc/soc_agentd.conf
  done
  if [ "$ZA_TLSCAFile" != "" ]; then
    echo TLSCAFile=${ZA_TLSCAFile} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_TLSCRLFile" != "" ]; then
    echo TLSCRLFile=${ZA_TLSCRLFile} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_TLSServerCertIssuer" != "" ]; then
    echo TLSServerCertIssuer=${ZA_TLSServerCertIssuer} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_TLSServerCertSubject" != "" ]; then
    echo TLSServerCertSubject=${ZA_TLSServerCertSubject} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_TLSCertFile" != "" ]; then
    echo TLSCertFile=${ZA_TLSCertFile} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_TLSKeyFile" != "" ]; then
    echo TLSKeyFile=${ZA_TLSKeyFile} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_TLSPSKIdentity" != "" ]; then
    echo TLSPSKIdentity=${ZA_TLSPSKIdentity} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_TLSPSKFile" != "" ]; then
    echo TLSPSKFile=${ZA_TLSPSKFile} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_SourceIP" != "" ]; then
    echo SourceIP=${ZA_SourceIP} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_LoadModulePath" != "" ]; then
    echo LoadModulePath=${ZA_LoadModulePath} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_UserParameter" != "" ]; then
    echo UserParameter=${ZA_UserParameter} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_HostMetadata" != "" ]; then
    echo HostMetadata=${ZA_HostMetadata} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_Include" != "" ]; then
    echo Include=${ZA_Include} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_Hostname" != "" ]; then
    echo Hostname=${ZA_Hostname} >> /usr/local/etc/soc_agentd.conf
  fi
  if [ "$ZA_HostnameItem" != "" ]; then
    echo HostnameItem=${ZA_HostnameItem} >> /usr/local/etc/soc_agentd.conf
  fi

  # ^ZW_: /usr/local/src/soc/frontends/php/conf/soc.conf.php
  export ZW_ZBX_SERVER_NAME_e=$(echo ${ZW_ZBX_SERVER_NAME} | sed -e 's/ /\\\ /g')
  sed -i "s#ZW_ZBX_SERVER_NAME#${ZW_ZBX_SERVER_NAME_e}#g" /usr/local/src/soc/frontends/php/conf/soc.conf.php
  unset ZW_ZBX_SERVER_NAME_e
  for i in $( set -o posix ; set | grep ^ZW_ | grep -v ^ZW_ZBX_SERVER_NAME | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#${reg}#${val}#g" /usr/local/src/soc/frontends/php/conf/soc.conf.php
  done

  # ^PHP_: /etc/php.d/soc.ini
  for i in $( set -o posix ; set | grep ^PHP_ | sort -rn ); do
    reg=$(echo ${i} | awk -F'=' '{print $1}')
    val=$(echo ${i} | awk -F'=' '{print $2}')
    sed -i "s#${reg}\$#${val}#g" /etc/php.d/soc.ini
  done

  if [ -f /etc/custom-config/php-soc.ini ]; then
    cp -f /etc/custom-config/php-soc.ini /etc/php.d/soc.ini
  fi
  if [ -f /etc/custom-config/soc_server.conf ]; then
    cp -f /etc/custom-config/soc_server.conf /usr/local/etc/soc_server.conf
  fi
}
####################### End of default settings #######################
# Zabbix default sql files
ZABBIX_SQL_DIR="/usr/local/src/soc/database/mysql"
# load DB config from custom config file if exist
if [ -f /etc/custom-config/soc_server.conf ]; then
  FZS_DBPassword=$(grep ^DBPassword= /etc/custom-config/soc_server.conf | awk -F= '{print $2}')
  if [ ! -z "$VAR" ]; then
    export ZS_DBPassword=$FZS_DBPassword
  fi
  FZS_DBUser=$(grep ^DBUser= /etc/custom-config/soc_server.conf | awk -F= '{print $2}')
  if [ ! -z "$FZS_DBUser" ]; then
    export ZS_DBUser=$FZS_DBUser
  fi
  FZS_DBHost=$(grep ^DBHost= /etc/custom-config/soc_server.conf | awk -F= '{print $2}')
  if [ ! -z "$FZS_DBHost" ]; then
    export ZS_DBHost=$FZS_DBHost
  fi
  FZS_DBPort=$(grep ^DBPort= /etc/custom-config/soc_server.conf | awk -F= '{print $2}')
  if [ ! -z "$FZS_DBPort" ]; then
    export ZS_DBPort=$FZS_DBPort
  fi
  FZS_DBName=$(grep ^ZS_DBName= /etc/custom-config/soc_server.conf | awk -F= '{print $2}')
  if [ ! -z "$FZS_DBName" ]; then
    export ZS_DBName=$FZS_DBName
  fi
fi
log "Preparing server configuration"
update_config
log "Config updated."
log "Enabling logging and pid management"
logging
system_pids
fix_permissions
log "Done"

if $ZS_enabled; then
  # wait 120sec for DB server initialization
  retry=24
  log "Waiting for database server"
  until mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -e "exit" &>/dev/null
  do
    log "Waiting for database server, it's still not available"
    retry=`expr $retry - 1`
    if [ $retry -eq 0 ]; then
      error "Database server is not available!"
      exit 1
    fi
    sleep 5
  done
  log "Database server is available"

  log "Checking if database exists or SQL import is required"
  if ! mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -e "use ${ZS_DBName};" &>/dev/null; then
    warning "Zabbix database doesn't exist. Installing and importing default settings"
    log `create_db`
    log "Database and user created, importing default SQL"
    log `import_soc_db`
    log "Import finished, starting"
  else
    log "Zabbix database exists, starting server"
  fi
else
  # Zabbix server is disabled
  rm -rf /etc/supervisor.d/soc-server.conf
fi

if ! $ZA_enabled; then
  # Zabbix agent is disabled
  rm -rf /etc/supervisor.d/soc-agent.conf
fi

if ! $ZW_enabled; then
  # Zabbix web UI is disabled
  rm -rf /etc/supervisor.d/nginx.conf
  rm -rf /etc/supervisor.d/php-fpm.conf
fi

if ! $SNMPTRAP_enabled; then
  # SNMP trap process is disabled
  rm -rf /etc/supervisor.d/snmptrapd.conf
  rm -rf /etc/logrotate.d/soc-traps
fi

# Zabbix version detection
export ZABBIX_VERSION=$(soc_server -V | grep Zabbix | awk '{print $3}')

log "Starting Zabbix version $ZABBIX_VERSION"
