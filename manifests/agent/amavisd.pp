#
# @summary
#   Install sensor for amavisd
#
# @example
#   include zabbix::agent::amavisd
#
class zabbix::agent::amavisd (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  include zabbix::agent::logtail

  case $facts['os']['family'] {
    default: {
      # No action taken. Install libdbi-perl manually
    }
    /(Debian|Ubuntu)/: {
      package { 'libdbi-perl':
        ensure => installed,
        before => File["${dir_zabbix_agent_libdir}/amavisd.pl"],
      }
    }
  }

  file { "${conf_dir}/amavisd.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/amavisd.conf.erb'),
    notify  => Service[$agent_service],
    require => Package[$agent_package],
  }

  file { "${dir_zabbix_agent_libdir}/amavisd.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/amavisd.pl',
    notify => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/check_amavis.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/check_amavis.pl',
    notify => Service[$agent_service],
  }

}
