#
# = Class: zabbix::agent::proxy
#
# This module installs zabbix proxy monitoring plugin
#
class zabbix::agent::proxy (
  $options                 = '',
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_proxy':
    command          => '/usr/bin/php /var/www/merlin/2017-2018/local/ceu/test_proxy.php',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring proxy.',
  }

  file { "${conf_dir}/proxy.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/proxy.conf.erb'),
    notify  => Service[$agent_service],
    require => ::Sudoers::Allowed_command['zabbix_proxy'],
  }

  file { "${dir_zabbix_agent_libdir}/proxy.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/proxy.pl',
    notify  => Service[$agent_service],
    require => ::Sudoers::Allowed_command['zabbix_proxy'],
  }

}
