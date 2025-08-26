# @summary
#   This class installs zabbix agent2 package
#   and handles related resources.
#
# @api private
#
class zabbix::agent2::install {
  package { $zabbix::agent2::package_name:
    ensure => $zabbix::agent2::package_ensure,
  }

  group { $zabbix::agent2::group:
    ensure  => present,
  }

  user { $zabbix::agent2::user:
    ensure  => present,
    gid     => $zabbix::agent2::group,
  }

  file { $zabbix::agent2::log_dir:
    ensure  => directory,
    owner   => $zabbix::agent2::user,
    group   => $zabbix::agent2::group,
    mode    => $zabbix::agent2::dir_mode,
  }
}
