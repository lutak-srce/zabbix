#
# = Class: zabbix::agent::megacli
#
# This module installs zabbix megacli plugin
#
class zabbix::agent::megacli (
  $conf_dir      = $::zabbix::agent::conf_dir,
  $agent_service = $::zabbix::agent::service_state,
  $agent_package = $::zabbix::agent::agent_package,
) inherits zabbix::agent {

  package { 'zabbix-agent_megacli':
    ensure  => present,
    require => Package[$agent_package],
  }

}
