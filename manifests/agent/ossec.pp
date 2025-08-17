# @summary 
#   Manages Zabbix agent configuration for ossec monitoring.
#
# @example
#   include zabbix::agent::ossec
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::ossec (
  $server_package = 'wazuh-manager',
) inherits zabbix::agent {
  ::sudoers::allowed_command { 'zabbix_sudo_ossec':
    command          => '/var/ossec/bin/agent_control -l',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring OSSEC/Wazuh agents.',
  }

  file { "${zabbix::agent::conf_dir}/ossec.conf":
    ensure  => file,
    content => template('zabbix/agent/ossec.conf.erb'),
    require => Package[$server_package],
  }
}
