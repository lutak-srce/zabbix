# @summary 
#   Manages Zabbix agent configuration for mdraid monitoring.
#
# @example
#   include zabbix::agent::mdraid
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::mdraid inherits zabbix::agent {
  ::sudoers::allowed_command { 'zabbix_sudo_mdadm':
    command          => '/sbin/mdadm --detail /dev/md[0-9]*',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix mdadm --detail listing',
  }

  file { "${zabbix::agent::conf_dir}/mdraid.conf":
    ensure  => file,
    content => template('zabbix/agent/mdraid.conf.erb'),
    require => File["${zabbix::agent::dir_zabbix_agent_libdir}/check_mdraid"],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/check_mdraid":
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/check_mdraid',
    require => ::Sudoers::Allowed_command['zabbix_sudo_mdadm'],
  }
}
