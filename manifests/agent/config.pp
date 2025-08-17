#
# = Define: zabbix::agent::config
#
# This define adds custom config file to Zabbix agent's conf
# directory.
define zabbix::agent::config (
  $settings,
) {
  file { "${zabbix::agent::conf_dir}/${name}.conf":
    ensure  => file,
    content => template('zabbix/custom.conf.erb'),
    require => File[$zabbix::agent::conf_dir],
  }

}
