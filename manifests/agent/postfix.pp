#
# @summary
#   Install sensor for postfix
#
# @example
#   include zabbix::agent::postfix
#
class zabbix::agent::postfix (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  include zabbix::agent::logtail

  case $facts['os']['family'] {
    default: {
      # No action taken. Install pflogsumm manually
    }
    /(Debian|Ubuntu)/: {
      package { 'pflogsumm':
        ensure => installed,
        before => File["${dir_zabbix_agent_libdir}/postfix.pl"],
      }
    }
  }

  sudoers::allowed_command { 'zabbix_postfix' :
    command          => "${dir_zabbix_agent_libdir}/postfix.pl",
    user             => 'zabbix',
    run_as           => 'ALL',
    require_password => false,
  }

  file { "${conf_dir}/postfix.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/postfix.conf.erb'),
    notify  => Service[$agent_service],
    require => Package[$agent_package],
  }

  file { "${dir_zabbix_agent_libdir}/postfix.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/postfix.pl',
    notify  => Service[$agent_service],
    require => ::Sudoers::Allowed_command['zabbix_postfix'],
  }

}
