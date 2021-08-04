#
# @summary
#   Install sensor for dovecot
#
# @example
#   include zabbix::agent::dovecot
#
class zabbix::agent::dovecot (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  package { 'libdovecot-zabbix-agent':
    ensure  => present,
    require => Package['zabbix-agent'],
  }

}
