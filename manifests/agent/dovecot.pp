#
# @summary
#   Install sensor for dovecot
#
# @example
#   include zabbix::agent::dovecot
#
class zabbix::agent::dovecot (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  include zabbix::agent::logtail

  file { "${dir_zabbix_agentd_confd}/dovecot.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/dovecot.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => Package['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/dovecot.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/dovecot.pl',
    notify => Service['zabbix-agent'],
  }

}
