# @summary 
#   Manages Zabbix agent configuration for zabbix proxy monitoring.
#
# @example
#   include zabbix::agent::proxy
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::proxy inherits zabbix::agent {
  ::sudoers::allowed_command { 'zabbix_proxy':
    command          => '/usr/bin/php /var/www/merlin/2017-2018/local/ceu/test_proxy.php',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring proxy.',
  }

  file { "${zabbix::agent::conf_dir}/proxy.conf":
    ensure  => file,
    content => template('zabbix/agent/proxy.conf.erb'),
    require => ::Sudoers::Allowed_command['zabbix_proxy'],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/proxy.pl":
    ensure  => file,
    mode    => $zabbix::agent::lib_file_mode,
    source  => 'puppet:///modules/zabbix/agent/proxy.pl',
    require => ::Sudoers::Allowed_command['zabbix_proxy'],
  }
}
