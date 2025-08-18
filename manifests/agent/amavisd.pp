# @summary 
#   Manages Zabbix agent configuration for amavisd monitoring.
#
# @example
#   include zabbix::agent::amavisd
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::amavisd inherits zabbix::agent {
  include zabbix::agent::logtail

  case $facts['os']['family'] {
    default: {
      # No action taken. Install libdbi-perl manually
    }
    /(Debian|Ubuntu)/: {
      package { 'libdbi-perl':
        ensure => installed,
        before => File["${zabbix::agent::dir_zabbix_agent_libdir}/amavisd.pl"],
      }
    }
  }

  file { "${zabbix::agent::conf_dir}/amavisd.conf":
    ensure  => file,
    content => template('zabbix/agent/amavisd.conf.erb'),
    require => [ 
      File["${zabbix::agent::dir_zabbix_agent_libdir}/amavisd.pl"],
      File["${zabbix::agent::dir_zabbix_agent_libdir}/check_amavis.pl"],
    ],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/amavisd.pl":
    ensure => file,
    mode   => $zabbix::agent::lib_file_mode,
    source => 'puppet:///modules/zabbix/agent/amavisd.pl',
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/check_amavis.pl":
    ensure => file,
    mode   => $zabbix::agent::lib_file_mode,
    source => 'puppet:///modules/zabbix/agent/check_amavis.pl',
  }
}
