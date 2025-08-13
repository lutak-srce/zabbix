#
# @summary
#   Install sensor for postfix
#
# @example
#   include zabbix::agent::postfix
#
class zabbix::agent::postfix (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  sudoers::allowed_command { 'zabbix_postfix' :
    command          => "${dir_zabbix_agent_libdir}/postfix.pl",
    user             => 'zabbix',
    run_as           => 'ALL',
    require_password => false,
  }

  file { "${dir_zabbix_agentd_confd}/postfix.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/postfix.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => Package['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/postfix.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/postfix.pl',
    notify  => Service['zabbix-agent'],
    require => ::Sudoers::Allowed_command['zabbix_postfix'],
  }

}
