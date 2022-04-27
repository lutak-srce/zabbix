#
# = Class: zabbix::agent::mailcheck
#
# This module installs zabbix mailcheck sensor
#
class zabbix::agent::mailcheck (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  package { 'msmtp':
    ensure  => present,
    require => Package['zabbix-agent'],
  }

  file { "/etc/msmtprc":
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/zabbix/agent/mailcheck/msmtprc',
    require => Package['msmtp'],
  }

  file { "${dir_zabbix_agent_libdir}/mail_check.php":
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/zabbix/agent/mailcheck/mail_check.php',
  }

  file { "${dir_zabbix_agent_libdir}/mail_send.php":
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/zabbix/agent/mailcheck/mail_send.php',
  }

  create_resources( zabbix::agent::mailcheck::conf, lookup( zabbix::agent::mailcheck::conf, Hash, {strategy => deep, merge_hash_arrays => true}))

}
