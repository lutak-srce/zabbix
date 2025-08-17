#
# Class: zabbix::agent
#
# This module manages zabbix-agent
#
class zabbix::agent (
  $package                    = $::zabbix::params::agent_package,
  $version                    = $::zabbix::params::agent_version,
  $service                    = $::zabbix::params::agent_service,
  $status                     = $::zabbix::params::agent_status,
  $file_owner                 = $::zabbix::params::agent_file_owner,
  $file_group                 = $::zabbix::params::agent_file_group,
  $file_mode                  = $::zabbix::params::agent_file_mode,
  $purge_conf_dir             = $::zabbix::params::agent_purge_conf_dir,
  $file_zabbix_agentd_conf    = $::zabbix::params::file_zabbix_agentd_conf,
  $erb_zabbix_agentd_conf     = 'zabbix/zabbix_agentd.conf.erb',
  $dir_zabbix_agentd_confd    = $::zabbix::params::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir    = $::zabbix::params::dir_zabbix_agent_libdir,
  $dir_zabbix_agent_modules   = $::zabbix::params::dir_zabbix_agent_modules,
  $zabbix_agentd_logfile      = $::zabbix::params::zabbix_agentd_logfile,
  $zabbix_agent_pidfile       = $::zabbix::params::zabbix_agent_pidfile,
  $plugin_socket              = $::zabbix::params::plugin_socket,
  $control_socket             = $::zabbix::params::control_socket,
  $server_name                = 'mon',
  $server_active              = 'mon',
  $buffersend                 = 5,
  $buffersize                 = 100,
  $client_name                = $facts['networking']['fqdn'],
  $timeout                    = '30',
  $tls_connect                = 'unencrypted',
  $tls_accept                 = 'unencrypted',
  $tls_ca_file                = undef,
  $tls_cert_file              = undef,
  $tls_key_file               = undef,
  $autoload_configs           = false,
  Enum['1', '2'] $variant     = '1',

  # params to override conf_dir location on Debian/Ubuntu when using official upstream Zabbix packages
  $upstream                   = false,
  $dir_zabbix_agentd_d        = $::zabbix::params::dir_zabbix_agentd_d,

  # zabbix agent 2 params
  $agent2_package             = $::zabbix::params::agent2_package,
  $agent2_service             = $::zabbix::params::agent2_service,
  $dir_zabbix_agent2_d        = $::zabbix::params::dir_zabbix_agent2_d,
  $file_zabbix_agent2_conf    = $::zabbix::params::file_zabbix_agent2_conf,
  $erb_zabbix_agent2_conf     = 'zabbix/zabbix_agent2.conf.erb',
  $dir_zabbix_agent2_pluginsd = $::zabbix::params::dir_zabbix_agent2_pluginsd,
  $zabbix_agent2_logfile      = $::zabbix::params::zabbix_agent2_logfile,
  $zabbix_agent2_pidfile      = $::zabbix::params::zabbix_agent2_pidfile,
  $purge_plugins_dir          = false,

) inherits zabbix::params {

  if $variant == '2' {
    $agent_package    = $::zabbix::agent::agent2_package
    $service_state    = $::zabbix::agent::agent2_service
    $conf_dir         = $::zabbix::agent::dir_zabbix_agent2_d
    $conf_file        = $::zabbix::agent::file_zabbix_agent2_conf
    $agent_template   = $::zabbix::agent::erb_zabbix_agent2_conf
    $agent_pidfile    = $::zabbix::agent::zabbix_agent2_pidfile
    $agent_logfile    = $::zabbix::agent::zabbix_agent2_logfile
    $agent_purge      = $::zabbix::agent::package
  } elsif $variant == '1' and $upstream == true {
      $agent_package    = $::zabbix::agent::package
      $service_state    = $::zabbix::agent::service
      $conf_dir         = $::zabbix::agent::dir_zabbix_agentd_d
      $conf_file        = $::zabbix::agent::file_zabbix_agentd_conf
      $agent_template   = $::zabbix::agent::erb_zabbix_agentd_conf
      $agent_pidfile    = $::zabbix::agent::zabbix_agent_pidfile
      $agent_logfile    = $::zabbix::agent::zabbix_agentd_logfile
      $agent_purge      = $::zabbix::agent::agent2_package
    } else {
        $agent_package    = $::zabbix::agent::package
        $service_state    = $::zabbix::agent::service
        $conf_dir         = $::zabbix::agent::dir_zabbix_agentd_confd
        $conf_file        = $::zabbix::agent::file_zabbix_agentd_conf
        $agent_template   = $::zabbix::agent::erb_zabbix_agentd_conf
        $agent_pidfile    = $::zabbix::agent::zabbix_agent_pidfile
        $agent_logfile    = $::zabbix::agent::zabbix_agentd_logfile
        $agent_purge      = $::zabbix::agent::agent2_package
  }

  File {
    ensure  => file,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Package[$agent_package],
    notify  => Service[$service_state],
  }

  package { $agent_package :
    ensure => $version,
  }

  package { "purge conflicting agent variant ${agent_purge}":
    ensure => purged,
    name   => $agent_purge,
    before => Package[$agent_package],
  }

  service { $service_state:
    ensure  => running,
    enable  => true,
    require => Package[$agent_package],
  }

  file { $conf_file:
    content => template($agent_template),
  }

  file { $conf_dir:
    ensure  => directory,
    recurse => $purge_conf_dir,
    purge   => $purge_conf_dir,
  }

  if $::zabbix::agent::variant == '2' {
    file { $dir_zabbix_agent2_pluginsd:
      ensure  => directory,
      recurse => $purge_plugins_dir,
      purge   => $purge_plugins_dir,
      require => File[$conf_dir],
    }
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
    require => Package[$agent_package],
  }

  user { 'zabbix':
    require => Package[$agent_package],
  }

  # autoload configs from zabbix::agent::configs from hiera
  if ( $autoload_configs == true ) {
    $zabbix_agent_config_rules = hiera_hash('zabbix::agent::configs', {})
    create_resources(::zabbix::agent::config, $zabbix_agent_config_rules)
  }

}
