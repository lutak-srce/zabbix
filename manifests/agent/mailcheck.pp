# @summary 
#   Manages Zabbix agent configuration for mail monitoring.
#
# @example
#   include zabbix::agent::mailcheck
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::mailcheck (
  $mail_host     = 'imap.srce.hr',
  $mail_username = '',
  $mail_password = '',
) inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/mailcheck.conf":
    ensure  => file,
    content => template('zabbix/agent/mailcheck.conf.erb'),
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/mail_check.php":
    ensure => file,
    mode   => '0644',
    source => 'puppet:///modules/zabbix/agent/mailcheck/mail_check.php',
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/mail_send.php":
    ensure => file,
    mode   => '0644',
    source => 'puppet:///modules/zabbix/agent/mailcheck/mail_send.php',
  }
}
