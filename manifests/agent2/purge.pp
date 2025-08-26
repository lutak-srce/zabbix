# @summary
#   This class purges zabbix agent package.
#
# @api private
#
class zabbix::agent2::purge {
  package { $zabbix::agent2::legacy_agent:
    ensure => $zabbix::agent2::legacy_agent_ensure,
  }
}
