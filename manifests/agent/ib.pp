# @summary 
#   Manages Zabbix agent configuration for ib monitoring.
#
# @example
#   include zabbix::agent::ib
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::ib (
  $extended = 1,
  $period   = '',
) inherits zabbix::agent {
  ::sudoers::allowed_command { 'zabbix_sudo_ib':
    command          => '/usr/sbin/perfquery',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix Infiniband sensor',
  }

  file { "${zabbix::agent::conf_dir}/ib.conf":
    ensure  => file,
    content => template('zabbix/agent/ib.conf.erb'),
    require => [
      Package['infiniband-diags'],
      File["${zabbix::agent::dir_zabbix_agent_libdir}/zabbix-ib.pl"],
    ],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/zabbix-ib.pl":
    ensure  => file,
    mode    => $zabbix::agent::lib_file_mode,
    source  => 'puppet:///modules/zabbix/agent/zabbix-ib.pl',
    require => ::Sudoers::Allowed_command['zabbix_sudo_ib'],
  }
}
