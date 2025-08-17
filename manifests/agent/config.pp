#
# = Define: zabbix::agent::config
#
# This define adds custom config file to Zabbix agent's conf
# directory.
define zabbix::agent::config (
  $settings,
  $notify_service = true,
) {
  $service_to_notify = $notify_service ? {
    default => undef,
    true    => Service[$zabbix::agent::service_state],
  }

  file { "${zabbix::agent::conf_dir}/${name}.conf":
    ensure  => file,
    content => template('zabbix/custom.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$zabbix::agent::conf_dir],
    notify  => $service_to_notify,
  }

}
