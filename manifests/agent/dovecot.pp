#
# @summary
#   Install sensor for dovecot
#
# @example
#   include zabbix::agent::dovecot
#
class zabbix::agent::dovecot (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  include zabbix::agent::logtail

  file { "${conf_dir}/dovecot.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/dovecot.conf.erb'),
    notify  => Service[$agent_service],
    require => Package[$agent_package],
  }

  file { "${dir_zabbix_agent_libdir}/dovecot.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/dovecot.pl',
    notify => Service[$agent_service],
  }

}
