#
# Class: zabbix::agent2
#
# This module manages zabbix agent variant 2
#
class zabbix::agent2 (
  String               $package                = 'zabbix-agent2',
  String               $version                = 'present',
  String               $legacy_agent           = 'zabbix-agent',
  String               $legacy_agent_ensure    = 'purged',
  String               $service                = 'zabbix-agent2',
  String               $service_ensure         = 'running',
  Boolean              $service_enable         = true,
  String               $owner                  = 'root',
  String               $group                  = 'root',
  Stdlib::Filemode     $file_mode              = '0644',
  Stdlib::Filemode     $dir_mode               = '0755',
  Boolean              $purge_conf_dirs        = true,
  Stdlib::Absolutepath $zabbix_agent2_d        = '/etc/zabbix/zabbix_agent2.d',
  Stdlib::Absolutepath $zabbix_agent2_conf     = '/etc/zabbix/zabbix_agent2.conf',
  String               $zabbix_agent2_conf_epp = 'zabbix/agent2/zabbix_agent2.conf.epp',
  Stdlib::Absolutepath $plugins_d              = '/etc/zabbix/zabbix_agent2.d/plugins.d',
  Stdlib::Absolutepath $log_file               = '/var/log/zabbix/zabbix_agent2.log',
  Stdlib::Absolutepath $pid_file               = '/var/run/zabbix/zabbix_agent2.pid',
  Optional[String]     $plugin_socket          = undef,
  Optional[String]     $control_socket         = undef,
  Optional[String]     $host_metadata          = undef,
  String               $server_name            = '127.0.0.1',
  String               $server_active          = '127.0.0.1',
  Integer              $buffer_send            = 5,
  Integer              $buffer_size            = 100,
  String               $host_name              = $facts['networking']['fqdn'],
  Integer              $timeout                = 30,

) {
  package { $legacy_agent:
    ensure => $legacy_agent_ensure,
    before => Package[$package],
  }

  package { $package:
    ensure => $version,
  }

  service { $service:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package[$package],
  }

  file { $zabbix_agent2_d:
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    mode    => $dir_mode,
    recurse => $purge_conf_dirs,
    purge   => $purge_conf_dirs,
    force   => $purge_conf_dirs,
    require => Package[$package],
  }

  file { $zabbix_agent2_conf:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => $file_mode,
    content => epp($zabbix_agent2_conf_epp),
    require => File[$zabbix_agent2_d],
    notify  => Service[$service],
  }

  file { $plugins_d:
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    mode    => $dir_mode,
    recurse => $purge_conf_dirs,
    purge   => $purge_conf_dirs,
    force   => $purge_conf_dirs,
    require => File[$zabbix_agent2_d],
  }

  # enable zabbix plugins to run sudo
  ::sudoers::requiretty { 'zabbix_notty':
    requiretty => false,
    user       => 'zabbix',
    comment    => 'Allow user zabbix to run sudo without tty',
  }

  user { 'zabbix':
    ensure  => present,
    require => Package[$package],
  }

  group { 'zabbix':
    ensure  => present,
    require => Package[$package],
  }

  include zabbix::agent2::plugin::ceph
  include zabbix::agent2::plugin::docker
  include zabbix::agent2::plugin::memcached
  include zabbix::agent2::plugin::modbus
  include zabbix::agent2::plugin::mongodb
  include zabbix::agent2::plugin::mqtt
  include zabbix::agent2::plugin::mysql
  include zabbix::agent2::plugin::oracle
  include zabbix::agent2::plugin::postgresql
  include zabbix::agent2::plugin::redis
  include zabbix::agent2::plugin::smart
}
