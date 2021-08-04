#
# @summary
#   Install sensor for postfix
#
# @example
#   include zabbix::agent::postfix
#
class zabbix::agent::postfix (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  package { 'libpostfix-zabbix-agent':
    ensure  => present,
    require => Package['zabbix-agent'],
  }

}
