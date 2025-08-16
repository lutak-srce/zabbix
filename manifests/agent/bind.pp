#
# @summary
#   Install sensor for bind
#
# @example
#   include zabbix::agent::bind
#
class zabbix::agent::bind (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
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

  file { "${conf_dir}/bind.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/bind.conf.erb'),
    notify  => Service[$agent_service],
    require => Package[$agent_package],
  }

  file { "${dir_zabbix_agent_libdir}/bind.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/bind.pl',
    notify  => Service[$agent_service],
    require => [
      ::Sudoers::Allowed_command['zabbix_rndc'],
      ::Sudoers::Allowed_command['zabbix_named'],
    ],
  }

}
