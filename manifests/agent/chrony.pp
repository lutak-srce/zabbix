#
# = Class: zabbix::agent::chrony
#
# This module installs zabbix chrony plugin
#
class zabbix::agent::chrony (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/chrony.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/chrony.conf.erb'),
    notify  => Service['zabbix-agent'],
  }

}
