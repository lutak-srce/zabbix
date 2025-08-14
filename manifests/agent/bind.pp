#
# @summary
#   Install sensor for bind
#
# @example
#   include zabbix::agent::bind
#
class zabbix::agent::bind (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  sudoers::allowed_command { 'zabbix_rndc' :
    command          => '/usr/sbin/rndc stats',
    user             => 'zabbix',
    run_as           => 'ALL',
    require_password => false,
  }

  sudoers::allowed_command { 'zabbix_named' :
    command          => '/bin/rm -f /var/cache/bind/named.stats',
    user             => 'zabbix',
    run_as           => 'ALL',
    require_password => false,
  }

  file { "${dir_zabbix_agentd_confd}/bind.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/bind.conf.erb'),
    notify  => Service['zabbix-agent'],
    require => Package['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/bind.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/bind.pl',
    notify  => Service['zabbix-agent'],
    require => [
      ::Sudoers::Allowed_command['zabbix_rndc'],
      ::Sudoers::Allowed_command['zabbix_named'],
    ],
  }

}
