# @summary 
#   Manages Zabbix agent configuration for gpu monitoring.
#
# @example
#   include zabbix::agent::gpu
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::gpu inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/gpu.conf":
    ensure  => file,
    content => template('zabbix/agent/gpu.conf.erb'),
    require => [
      File["${zabbix::agent::dir_zabbix_agent_libdir}/get_gpu_info"],
      File["${zabbix::agent::dir_zabbix_agent_libdir}/get_gpus_info.sh"],
      Package['python35u'],
    ],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/get_gpu_info":
    ensure => file,
    mode   => $zabbix::agent::lib_file_mode,
    source => 'puppet:///modules/zabbix/agent/gpu/get_gpu_info',
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/get_gpus_info.sh":
    ensure => file,
    mode   => $zabbix::agent::lib_file_mode,
    source => 'puppet:///modules/zabbix/agent/gpu/get_gpus_info.sh',
  }
}
