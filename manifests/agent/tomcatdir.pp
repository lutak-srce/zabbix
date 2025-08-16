#
# = Class: zabbix::agent::tomcatdir
#
# This module installs Tomcat Git Repo sensor
#
class zabbix::agent::tomcatdir (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${conf_dir}/tomcatdir.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/tomcatdir.conf.erb'),
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/tomcat-dir.jar"],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/tomcat-dir.jar" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/tomcatdir/tomcat-dir.jar',
  }

}
