#
# @summary
#   Install sensor for amavisd
#
# @example
#   include zabbix::agent::amavisd
#
class zabbix::agent::amavisd (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  include zabbix::agent::logtail

  file { "${dir_zabbix_agentd_confd}/amavisd.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/amavisd.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => Package['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/amavisd.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/amavisd.pl',
    notify => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/check_amavis.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/check_amavis.pl',
    notify => Service['zabbix-agent'],
  }

}
