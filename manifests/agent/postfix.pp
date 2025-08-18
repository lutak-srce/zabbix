# @summary 
#   Manages Zabbix agent configuration for postfix monitoring.
#
# @example
#   include zabbix::agent::postfix
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::postfix inherits zabbix::agent {
  include zabbix::agent::logtail

  case $facts['os']['family'] {
    default: {
      # No action taken. Install pflogsumm manually
    }
    /(Debian|Ubuntu)/: {
      package { 'pflogsumm':
        ensure => installed,
        before => File["${zabbix::agent::dir_zabbix_agent_libdir}/postfix.pl"],
      }
    }
  }

  sudoers::allowed_command { 'zabbix_postfix':
    command          => "${zabbix::agent::dir_zabbix_agent_libdir}/postfix.pl",
    user             => 'zabbix',
    run_as           => 'ALL',
    require_password => false,
  }

  file { "${zabbix::agent::conf_dir}/postfix.conf":
    ensure  => file,
    content => template('zabbix/agent/postfix.conf.erb'),
    require => File["${zabbix::agent::dir_zabbix_agent_libdir}/postfix.pl"],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/postfix.pl":
    ensure  => file,
    mode    => $zabbix::agent::lib_file_mode,
    source  => 'puppet:///modules/zabbix/agent/postfix.pl',
    require => ::Sudoers::Allowed_command['zabbix_postfix'],
  }
}
