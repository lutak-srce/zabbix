# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring ceph.
#
# @example
#   include zabbix::agent2::plugin::ceph
#
class zabbix::agent2::plugin::ceph (
                                     $file_ensure          = $zabbix::agent::file_ensure,
  Optional[Boolean]                  $insecure_skip_verify = undef,
  Optional[Integer[60,900]]          $keep_alive           = undef,
  Optional[Integer[1,30]]            $timeout              = undef,
  Optional[Hash[String,
    Struct[{
        uri     => Stdlib::HTTPSUrl,
        user    => String[1],
        api_key => String[1],
    }]
  ]]                                 $sessions             = undef,
) {
  file { "${zabbix::agent2::plugins_d}/ceph.conf":
    ensure  => $file_ensure,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/ceph.conf.epp'),
    notify  => Service[$zabbix::agent2::service_name],
  }
}
