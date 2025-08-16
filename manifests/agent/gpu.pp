#
# = Class: zabbix::agent::gpu
#
# This module installs Zabbix GPU sensor
#
class zabbix::agent::gpu (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${conf_dir}/gpu.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/gpu.conf.erb'),
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/get_gpu_info"],
      File["${dir_zabbix_agent_libdir}/get_gpus_info.sh"],
      Package['python35u'],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/get_gpu_info" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/gpu/get_gpu_info',
  }

  file { "${dir_zabbix_agent_libdir}/get_gpus_info.sh" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/gpu/get_gpus_info.sh',
  }

}
