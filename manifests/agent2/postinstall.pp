# @summary
#   This class handles post-install tasks
#
# @api private
#
class zabbix::agent2::postinstall {
  group { $zabbix::agent2::group:
    ensure => present,
  }

  user { $zabbix::agent2::user:
    ensure => present,
    gid    => $zabbix::agent2::group,
  }

  file { $zabbix::agent2::log_dir:
    ensure => directory,
    owner  => $zabbix::agent2::user,
    group  => $zabbix::agent2::group,
    mode   => $zabbix::agent2::dir_mode,
  }
}
