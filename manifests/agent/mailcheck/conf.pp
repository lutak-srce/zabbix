#
# This module manages configuration file for zabbix::agent::mailcheck
#
define zabbix::agent::mailcheck::conf (
  $confname                = $name,
  $options                 = '',
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $mail_host               = 'imap.srce.hr',
  $mail_username           = '',
  $mail_password           = '',
) {

  file { "${dir_zabbix_agentd_confd}/mailcheck-${confname}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/mailcheck.conf.erb'),
    notify  => Service['zabbix-agent'],
  }

}
