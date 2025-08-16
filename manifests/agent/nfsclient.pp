#
# = Class: zabbix::agent::nfsclient
#
# This module installs NFS client monitoring plugin
#
class zabbix::agent::nfsclient (
  $options            = '',
  $conf_dir           = $::zabbix::agent::conf_dir,
  $agent_service      = $::zabbix::agent::service_state,
  $agent_package      = $::zabbix::agent::agent_package,
  $dir_for_monitoring = $::zabbix::agent::dir_for_monitoring,
) inherits zabbix::agent {

    if $dir_for_monitoring {
      file { "${conf_dir}/nfsclient.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('zabbix/agent/nfsclient.conf.erb'),
        notify  => Service[$agent_service],
      }
    }

    else {
      notify{'!!! zabbix::agent::dir_for_monitoring must be included defined !!!': }
    }

}
