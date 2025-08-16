#
# = Class: zabbix::agent::lld
#
# Adds some standard Low Level Discovery items
#
class zabbix::agent::lld (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_sudo_multipath':
    command          => '/sbin/multipath',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix LLD blockdev.',
  }

  file { "${conf_dir}/lld.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/lld/lld.conf.erb'),
    notify  => Service[$agent_service],
    require => Package[$agent_package],
  }

  file { "${dir_zabbix_agent_libdir}/lld-blockdev" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/lld/lld-blockdev',
    notify  => Service[$agent_service],
    require => ::Sudoers::Allowed_command['zabbix_sudo_multipath'],
  }

  file { "${dir_zabbix_agent_libdir}/lld-macro" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/lld/lld-macro',
    notify => Service[$agent_service],
  }
}
