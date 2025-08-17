# @summary 
#   Manages Zabbix agent configuration for lld discovery.
#
# @example
#   include zabbix::agent::lld
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::lld inherits zabbix::agent {
  ::sudoers::allowed_command { 'zabbix_sudo_multipath':
    command          => '/sbin/multipath',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix LLD blockdev.',
  }

  file { "${zabbix::agent::conf_dir}/lld.conf" :
    ensure  => file,
    content => template('zabbix/lld/lld.conf.erb'),
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/lld-blockdev" :
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/lld/lld-blockdev',
    require => ::Sudoers::Allowed_command['zabbix_sudo_multipath'],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/lld-macro" :
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/lld/lld-macro',
  }
}
