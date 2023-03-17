#
# Class: zabbix::agent
#
# This module manages zabbix-agent
#
class zabbix::agent (

  $package                  = $::zabbix::params::agent_package,

  $version                  = $::zabbix::params::agent_version,
  $service                  = $::zabbix::params::agent_service,
  $file_zabbix_agentd_conf  = $::zabbix::params::file_zabbix_agentd_conf,
  $erb_zabbix_agentd_conf   = $::zabbix::params::erb_zabbix_agentd_conf,
  $dir_zabbix_agentd_confd  = $::zabbix::params::dir_zabbix_agentd_confd,
  $zabbix_agentd_logfile    = $::zabbix::params::zabbix_agentd_logfile,
  $zabbix_agent_pidfile     = $::zabbix::params::zabbix_agent_pidfile,
  
  $status                   = $::zabbix::params::agent_status,
  $file_owner               = $::zabbix::params::agent_file_owner,
  $file_group               = $::zabbix::params::agent_file_group,
  $file_mode                = $::zabbix::params::agent_file_mode,
  $purge_conf_dir           = $::zabbix::params::agent_purge_conf_dir,
  
  $dir_zabbix_agent_libdir  = $::zabbix::params::dir_zabbix_agent_libdir,
  $dir_zabbix_agent_modules = $::zabbix::params::dir_zabbix_agent_modules,
  
  
  $server_name              = 'mon',
  $server_active            = 'mon',
  $buffersend               = 5,
  $buffersize               = 100,
  $client_name              = $::fqdn,
  $timeout                  = '30',
  $tls_connect              = 'unencrypted',
  $tls_accept               = 'unencrypted',
  $tls_ca_file              = undef,
  $tls_cert_file            = undef,
  $tls_key_file             = undef,
  $autoload_configs         = false,
) inherits zabbix::params {

  if ($package == 'zabbix-agent2') {
    $package                  = 'zabbix-agent2',
    $version                  = 'zabbix-agent2',
    $service                  = 'zabbix-agent2',
    $file_zabbix_agentd_conf  = '/etc/zabbix/zabbix_agent2.conf',
    $erb_zabbix_agentd_conf   = 'zabbix/zabbix_agent2.conf.erb',
    $dir_zabbix_agentd_confd  = '/etc/zabbix/zabbix_agent2.d',
    $zabbix_agentd_logfile    = 'var/log/zabbix/zabbix_agent2.log',
    $zabbix_agent_pidfile     = '/var/run/zabbix/zabbix_agent2.pid',
  }
  
  File {
    ensure  => file,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Package[$package],
    notify  => Service[$service],
  }

  package { $package:
    ensure => $version,
    alias  => $package,
  }

  service { $service:
    ensure  => running,
    name    => $service,
    enable  => true,
    require => Package[$package],
  }

  file { $file_zabbix_agentd_conf:
    path    => $file_zabbix_agentd_conf,
    content => template($erb_zabbix_agentd_conf),
  }

  file { 'zabbix_agent_confd':
    ensure  => directory,
    path    => $dir_zabbix_agentd_confd,
    recurse => $purge_conf_dir,
    purge   => $purge_conf_dir,
  }

  file { 'zabbix_agent_libdir':
    ensure => directory,
    path   => $dir_zabbix_agent_libdir,
  }

  file { 'zabbix_agent_modules':
    ensure  => directory,
    path    => $dir_zabbix_agent_modules,
    require => File['zabbix_agent_libdir'],
  }

  # enable zabbix plugins to run sudo
  ::sudoers::requiretty { 'zabbix_notty':
    requiretty => false,
    user       => 'zabbix',
    comment    => 'Allow user zabbix to run sudo without tty',
  }

  # compatibilty needed for zabbix agent sensors (sudoers)
  group { 'zabbix':
    require => Package[$package],
  }

  user { 'zabbix':
    require => Package[$package],
  }

  # autoload configs from zabbix::agent::configs from hiera
  if ( $autoload_configs == true ) {
    $zabbix_agent_config_rules = hiera_hash('zabbix::agent::configs', {})
    create_resources(::zabbix::agent::config, $zabbix_agent_config_rules)
  }

}
