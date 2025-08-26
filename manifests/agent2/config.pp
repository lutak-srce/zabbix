# @summary
#   This class handles zabbix agent2 configuration.
#
# @api private
#
class zabbix::agent2::config {
  file { $zabbix::agent2::log_dir:
    ensure  => directory,
    owner   => $zabbix::agent2::user,
    group   => $zabbix::agent2::group,
    mode    => $zabbix::agent2::dir_mode,
  }

  file { $zabbix::agent2::conf_dir:
    ensure  => directory,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::dir_mode,
    recurse => $zabbix::agent2::file_recurse,
    purge   => $zabbix::agent2::file_purge,
    force   => $zabbix::agent2::file_force,
  }

  file { $zabbix::agent2::zabbix_agent2_d:
    ensure  => directory,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::dir_mode,
    recurse => $zabbix::agent2::file_recurse,
    purge   => $zabbix::agent2::file_purge,
    force   => $zabbix::agent2::file_force,
  }

  file { $zabbix::agent2::plugins_d:
    ensure  => directory,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::dir_mode,
    recurse => $zabbix::agent2::file_recurse,
    purge   => $zabbix::agent2::file_purge,
    force   => $zabbix::agent2::file_force,
  }

  file { $zabbix::agent2::zabbix_agent2_conf:
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp($zabbix::agent2::zabbix_agent2_conf_epp, $zabbix::agent2::parameters),
  }

  user { $zabbix::agent2::user:
    ensure  => present,
    gid     => $zabbix::agent2::group,
  }

  group { $zabbix::agent2::group:
    ensure  => present,
  }

  # include config files of inbuilt or dependant plugins
  contain zabbix::agent2::plugin::ceph
  contain zabbix::agent2::plugin::docker
  contain zabbix::agent2::plugin::memcached
  contain zabbix::agent2::plugin::modbus
  contain zabbix::agent2::plugin::mongodb
  contain zabbix::agent2::plugin::mqtt
  contain zabbix::agent2::plugin::mysql
  contain zabbix::agent2::plugin::oracle
  contain zabbix::agent2::plugin::postgresql
  contain zabbix::agent2::plugin::redis
  contain zabbix::agent2::plugin::smart
}
