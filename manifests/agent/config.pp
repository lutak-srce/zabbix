#
# = Define: zabbix::agent::config
#
# This define adds custom config file to Zabbix agent's conf
# directory.
define zabbix::agent::config (
  $settings,
  $conf_dir       = $zabbix::agent::conf_dir,
  $agent_service  = $zabbix::agent::agent_service,
  $notify_service = true,
) {
  include ::zabbix::agent

  $service_to_notify = $notify_service ? {
    default => undef,
    true    => Service[$agent_service],
  }

  file { "${conf_dir}/${name}.conf":
    ensure  => file,
    content => template('zabbix/custom.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$conf_dir],
    notify  => $service_to_notify,
  }

}
