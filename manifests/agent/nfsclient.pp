# @summary 
#   Manages Zabbix agent configuration for nfsclient monitoring.
#
# @example
#   include zabbix::agent::nfsclient
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::nfsclient (
  $dir_for_monitoring = $zabbix::agent::dir_for_monitoring,
) inherits zabbix::agent {
  if $dir_for_monitoring {
    file { "${zabbix::agent::conf_dir}/nfsclient.conf":
      ensure  => file,
      content => template('zabbix/agent/nfsclient.conf.erb'),
    }
  } else {
    notify{'!!! zabbix::agent::dir_for_monitoring must be included defined !!!': }
  }
}
