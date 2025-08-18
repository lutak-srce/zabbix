# @summary 
#   Manages Zabbix agent configuration for tomcatdir monitoring.
#
# @example
#   include zabbix::agent::tomcatdir
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::tomcatdir inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/tomcatdir.conf":
    ensure  => file,
    content => template('zabbix/agent/tomcatdir.conf.erb'),
    require => File["${zabbix::agent::dir_zabbix_agent_libdir}/tomcat-dir.jar"],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/tomcat-dir.jar":
    ensure => file,
    mode   => $zabbix::agent::lib_file_mode,
    source => 'puppet:///modules/zabbix/agent/tomcatdir/tomcat-dir.jar',
  }
}
