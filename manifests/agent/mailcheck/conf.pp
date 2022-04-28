#
# This module manages configuration file for zabbix::agent::mailcheck
#
define zabbix::agent::mailcheck::conf (
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $imap_host,
  $mail_password,
  $mail_username,
  $smtp_host,
) {

  file { "${dir_zabbix_agentd_confd}/mailcheck-${name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/mailcheck.conf.erb'),
    notify  => Service['zabbix-agent'],
  }

}
