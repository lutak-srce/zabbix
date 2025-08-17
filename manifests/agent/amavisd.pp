#
# @summary
#   Install sensor for amavisd
#
# @example
#   include zabbix::agent::amavisd
#
class zabbix::agent::amavisd inherits zabbix::agent {
  include zabbix::agent::logtail

  case $facts['os']['family'] {
    default: {
      # No action taken. Install libdbi-perl manually
    }
    /(Debian|Ubuntu)/: {
      package { 'libdbi-perl':
        ensure => installed,
        before => File["${zabbix::agent::dir_zabbix_agent_libdir}/amavisd.pl"],
      }
    }
  }

  file { "${zabbix::agent::conf_dir}/amavisd.conf" :
    ensure  => file,
    content => template('zabbix/agent/amavisd.conf.erb'),
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/amavisd.pl" :
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/amavisd.pl',
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/check_amavis.pl" :
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/check_amavis.pl',
  }
}
