# @summary 
#   Manages Zabbix agent configuration for SGE monitoring.
#
# @example
#   include zabbix::agent::sge
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::sge inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/sge.conf":
    ensure  => file,
    content => template('zabbix/agent/sge.conf.erb'),
    require => [
      File["${zabbix::agent::dir_zabbix_agent_libdir}/sge.pl"],
      File["${zabbix::agent::dir_zabbix_agent_libdir}/sge-lld.pl"],
      Package['perl-JSON'],
    ],
  }

  package { 'perl-JSON':
    ensure =>   present
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/sge.pl":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/sge/sge.pl',
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/sge-lld.pl":
    ensure => file,
    mode   => '0755',
    source =>  'puppet:///modules/zabbix/agent/sge/sge-lld.pl',
  }
}
