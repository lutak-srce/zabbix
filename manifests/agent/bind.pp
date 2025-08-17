# @summary 
#   Manages Zabbix agent configuration for bind monitoring.
#
# @example
#   include zabbix::agent::bind
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::bind inherits zabbix::agent {
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

  file { "${zabbix::agent::conf_dir}/bind.conf" :
    ensure  => file,
    content => template('zabbix/agent/bind.conf.erb'),
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/bind.pl" :
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/bind.pl',
    require => [
      ::Sudoers::Allowed_command['zabbix_rndc'],
      ::Sudoers::Allowed_command['zabbix_named'],
    ],
  }
}
