# @summary 
#   Manages Zabbix agent configuration for puppet agent monitoring.
#
# @example
#   include zabbix::agent::puppet_agent
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::puppet_agent inherits zabbix::agent {
  sudoers::allowed_command { 'zabbix_puppet_agent' :
    command          => "${zabbix::agent::dir_zabbix_agent_libdir}/puppet_agent",
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring Puppet agent.',
  }

  file { "${zabbix::agent::conf_dir}/puppet_agent.conf" :
    ensure  => file,
    content => template('zabbix/agent/puppet_agent.conf.erb'),
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/puppet_agent" :
    ensure  => file,
    mode    => '0755',
    content => template('zabbix/agent/puppet_agent.erb'),
    require => ::Sudoers::Allowed_command['zabbix_puppet_agent'],
  }
}
