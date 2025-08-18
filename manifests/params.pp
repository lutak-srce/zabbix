#
# Class: zabbix::params
#
# This module contains defaults for other zabbix modules
#
class zabbix::params {
  # general zabbix settings
  $ensure        = 'present'
  $server_name   = 'mon'
  $server_active = 'mon'
  $client_name   = $facts['networking']['fqdn']

  # conf dir common accross both Zabbix agent variants in upstream packages
  $dir_zabbix_agentd_d = '/etc/zabbix/zabbix_agentd.d'

  # agent settings
  $agent_file_owner        = 'root'
  $agent_file_group        = 'root'
  $agent_file_mode         = '0644'
  $agent_lib_file_mode     = '0755'
  $agent_purge_conf_dir    = false
  $get_package             = 'zabbix-get'
  $get_version             = 'present'
  $sender_package          = 'zabbix-sender'
  $sender_version          = 'present'
  $agent_package           = 'zabbix-agent'
  $agent_version           = 'present'
  $agent_service           = 'zabbix-agent'
  $agent_status            = 'enabled'
  $file_zabbix_agentd_conf = '/etc/zabbix/zabbix_agentd.conf'
  $zabbix_agent_pidfile    = '/var/run/zabbix/zabbix_agentd.pid'
  # OS family specific params
  case $facts['os']['family'] {
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $dir_zabbix_agentd_confd  = '/etc/zabbix/zabbix_agentd.conf.d'
      $dir_zabbix_agent_libdir  = '/usr/lib/zabbix-agent'
      $dir_zabbix_agent_modules = '/usr/lib/zabbix-agent/modules'
      $zabbix_agentd_logfile    = '/var/log/zabbix-agent/zabbix_agentd.log'
    }
    /(RedHat|redhat|amazon)/: {
      $dir_zabbix_agentd_confd  = '/etc/zabbix/zabbix_agentd.d'
      $dir_zabbix_agent_libdir  = '/usr/libexec/zabbix-agent'
      $dir_zabbix_agent_modules = '/usr/libexec/zabbix-agent/modules'
      $zabbix_agentd_logfile    = '/var/log/zabbix/zabbix_agentd.log'
    }
    default: {
      $dir_zabbix_agentd_confd  = '/etc/zabbix/zabbix_agentd.d'
      $dir_zabbix_agent_libdir  = '/usr/lib/zabbix/agent'
      $dir_zabbix_agent_modules = '/usr/lib/zabbix/agent/modules'
      $zabbix_agentd_logfile    = '/var/log/zabbix/zabbix_agentd.log'
    }
  }


  # agent2 settings
  $agent2_package             = 'zabbix-agent2'
  $agent2_service             = 'zabbix-agent2'
  $dir_zabbix_agent2_d        = '/etc/zabbix/zabbix_agent2.d'
  $file_zabbix_agent2_conf    = '/etc/zabbix/zabbix_agent2.conf'
  $dir_zabbix_agent2_pluginsd = '/etc/zabbix/zabbix_agent2.d/plugins.d'
  $zabbix_agent2_logfile      = '/var/log/zabbix/zabbix_agent2.log'
  $zabbix_agent2_pidfile      = '/var/run/zabbix/zabbix_agent2.pid'
  $plugin_socket              = undef
  $control_socket             = undef

  # server settings
  $server_file_owner       = 'root'
  $server_file_group       = 'root'
  $server_file_mode        = '0644'
  $server_purge_conf_dir   = false
  $server_package          = 'zabbix-server'
  $server_version          = 'present'
  $server_service          = 'zabbix-server'
  $server_status           = 'enabled'
  $file_zabbix_server_conf = '/etc/zabbix/zabbix_server.conf'
  $dir_zabbix_server_confd = '/etc/zabbix/zabbix_server.d'
  # OS family specific params
  case $facts['os']['family'] {
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $zabbix_server_logfile = '/var/log/zabbix/zabbix_server.log'
      $zabbix_server_pidfile = '/var/run/zabbix/zabbix_server.pid'
      $fpinglocation         = '/usr/bin/fping'
      $fping6location        = '/usr/bin/fping6'
      $alert_scripts_path    = '/usr/lib/zabbix/alertscripts'
      $external_scripts      = '/usr/lib/zabbix/externalscripts'
      $tmpdir                = '/tmp'
    }
    /(RedHat|redhat|amazon)/: {
      $zabbix_server_logfile = '/var/log/zabbixsrv/zabbix_server.log'
      $zabbix_server_pidfile = '/var/run/zabbixsrv/zabbix_server.pid'
      $fpinglocation         = '/usr/sbin/fping'
      $fping6location        = '/usr/sbin/fping6'
      $alert_scripts_path    = '/var/lib/zabbixsrv/alertscripts'
      $external_scripts      = '/var/lib/zabbixsrv/externalscripts'
      $tmpdir                = '/var/lib/zabbixsrv/tmp'
    }
    default: {
      $zabbix_server_logfile = '/var/log/zabbix/zabbix_server.log'
      $zabbix_server_pidfile = '/var/run/zabbix/zabbix_server.pid'
      $fpinglocation         = '/usr/bin/fping'
      $fping6location        = '/usr/bin/fping6'
      $alert_scripts_path    = '/var/lib/zabbixsrv/alertscripts'
      $external_scripts      = '/var/lib/zabbixsrv/externalscripts'
      $tmpdir                = '/tmp'
    }
  }


  # proxy settings
  $proxy_file_owner       = 'root'
  $proxy_file_group       = 'zabbix'
  $proxy_file_mode        = '0640'
  $proxy_purge_conf_dir   = false
  $proxy_package          = 'zabbix-proxy'
  $proxy_version          = 'present'
  $proxy_service          = 'zabbix-proxy'
  $proxy_status           = 'enabled'
  $proxy_logfile          = '/var/log/zabbix/zabbix_proxy.log'
  $proxy_pidfile          = '/var/run/zabbix/zabbix_proxy.pid'
  $file_zabbix_proxy_conf = '/etc/zabbix/zabbix_proxy.conf'

  # java gateway settings
  $java_gateway_file_owner = 'root'
  $java_gateway_file_group = 'root'
  $java_gateway_file_mode  = '0644'
  $pid_file_zabbix_javagw  = '/var/run/zabbix/zabbix_java_gateway.pid'
  $java_gateway_package    = 'zabbix-java-gateway'
  $java_gateway_version    = 'present'
  $java_gateway_service    = 'zabbix-java-gateway'
  $java_gateway_status     = 'enabled'
  $file_zabbix_javagw_conf = '/etc/zabbix/zabbix_java_gateway.conf'

  # web settings
  $web_version        = 'present'
  $web_file_owner     = 'root'
  $web_file_mode      = '0640'
  $web_dir_zabbix_php = '/etc/zabbix/web'
  # OS family specific params
  case $facts['os']['family'] {
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $web_package    = 'zabbix-frontend-php'
      $web_file_group = 'www-data'
    }
    default: {
      $web_package    = 'zabbix-web'
      $web_file_group = 'root'
    }
  }


  # module dependencies
  $dependency_class = 'zabbix::dependency'
  $my_class         = undef

}
