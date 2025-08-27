#
# Class: zabbix::agent2
#
# This module manages zabbix agent variant 2
#
class zabbix::agent2 (
  String               $package_name           = 'zabbix-agent2',
  String               $package_ensure         = present,
  String               $zabbix_agent           = 'zabbix-agent',
  String               $zabbix_agent_ensure    = purged,
  String               $user                   = 'zabbix',
  String               $group                  = 'zabbix',
  String               $service_name           = 'zabbix-agent2',
  String               $service_ensure         = running,
  Boolean              $service_enable         = true,
  String               $file_ensure            = present,
  String               $file_owner             = 'root',
  String               $file_group             = 'root',
  Stdlib::Filemode     $file_mode              = '0644',
  Boolean              $file_recurse           = true,
  Boolean              $file_purge             = true,
  Boolean              $file_force             = true,
  Stdlib::Filemode     $dir_mode               = '0755',
  Stdlib::Absolutepath $conf_dir               = '/etc/zabbix',
  Stdlib::Absolutepath $log_dir                = '/var/log/zabbix',
  Stdlib::Absolutepath $zabbix_agent2_d        = '/etc/zabbix/zabbix_agent2.d',
  Stdlib::Absolutepath $zabbix_agent2_conf     = '/etc/zabbix/zabbix_agent2.conf',
  String               $zabbix_agent2_conf_epp = 'zabbix/agent2/zabbix_agent2.conf.epp',
  Stdlib::Absolutepath $plugins_d              = '/etc/zabbix/zabbix_agent2.d/plugins.d',
  String               $is_service_active_cmd  = '/usr/bin/systemctl is-active',
  # General parameters
  Stdlib::Absolutepath                        $pid_file      = '/var/run/zabbix/zabbix_agent2.pid',
  Optional[Enum['system', 'file', 'console']] $log_type      = undef,
  Stdlib::Absolutepath                        $log_file      = '/var/log/zabbix/zabbix_agent2.log',
  Integer[0,1024]                             $log_file_size = 0,
  Optional[Integer[0,5]]                      $debug_level   = undef,
  Optional[Stdlib::IP::Address]               $source_ip     = undef,
  # Passive checks related
  Variant[Stdlib::Host, Array[Stdlib::Host,1]]                         $server      = '127.0.0.1',
  Optional[Integer[1024,32767]]                                        $listen_port = undef,
  Optional[Variant[Stdlib::IP::Address, Array[Stdlib::IP::Address,1]]] $listen_ip   = undef,
  Optional[Integer[1024,32767]]                                        $status_port = undef,
  # Active checks related
  Variant[String[1], Array[String[1]]]                   $server_active            = '127.0.0.1',
  Variant[String[1], Array[String[1]]]                   $hostname                 = $facts['networking']['fqdn'],
  Optional[String[1,255]]                                $hostname_item            = undef,
  Optional[Variant[String[1,255], Array[String[1,255]]]] $host_metadata            = undef,
  Optional[String[1,255]]                                $host_metadata_item       = undef,
  Optional[String[1,255]]                                $host_interface           = undef,
  Optional[String[1,255]]                                $host_interface_item      = undef,
  Optional[Integer[60,3600]]                             $refresh_active_checks    = undef,
  Optional[Integer[1,3600]]                              $buffer_send              = undef,
  Optional[Integer[2,65535]]                             $buffer_size              = undef,
  Optional[Integer[0,1]]                                 $enable_persistent_buffer = undef,
  Optional[String]                                       $persistent_buffer_period = undef,
  Optional[Stdlib::Absolutepath]                         $persistent_buffer_file   = undef,
  # Advanced parameters
  Optional[Array[String]] $alias          = undef,
  Optional[Integer[1,30]] $timeout        = undef,
  Optional[Integer[1,30]] $plugin_timeout = undef,
  Stdlib::Absolutepath    $plugin_socket  = '/var/run/zabbix/agent.plugin.sock',
  # User-defined monitored parameters
  Optional[Integer[0,1]]         $unsafe_user_parameters = undef,
  Optional[Array[Struct[{
    key           => String[1],
    shell_command => String[1],
  }]]]                           $user_parameter         = undef,
  Optional[Stdlib::Absolutepath] $user_parameter_dir     = undef,
  Stdlib::Absolutepath           $control_socket         = '/var/run/zabbix/agent.sock',
  # TLS-related parameters
  Optional[Variant[Enum['unencrypted', 'psk', 'cert'],
    Array[Enum['unencrypted', 'psk', 'cert'],1]]]      $tls_connect             = undef,
  Optional[Variant[Enum['unencrypted', 'psk', 'cert'],
    Array[Enum['unencrypted', 'psk', 'cert'],1]]]      $tls_accept              = undef,
  Optional[Stdlib::Absolutepath]                       $tls_ca_file             = undef,
  Optional[Stdlib::Absolutepath]                       $tls_crl_file            = undef,
  Optional[String]                                     $tls_server_cert_issuer  = undef,
  Optional[String]                                     $tls_server_cert_subject = undef,
  Optional[Stdlib::Absolutepath]                       $tls_cert_file           = undef,
  Optional[Stdlib::Absolutepath]                       $tls_key_file            = undef,
  Optional[String]                                     $tls_psk_identity        = undef,
  Optional[Stdlib::Absolutepath]                       $tls_psk_file            = undef,
  # Plugin-specific parameters
  Optional[Hash[
    String[1],
    Hash[
      String[1],
      String[1]
    ]
  ]]                        $plugins                                = undef,
  Optional[Integer[1,1000]] $plugins_log_max_lines_per_second       = undef,
  Optional[Array[String]]   $allow_key                              = undef,
  Optional[Array[String]]   $deny_key                               = undef,
  Optional[Integer[0,1]]    $plugins_system_run_log_remote_commands = undef,
  Optional[Integer[0,1]]    $force_active_checks_on_start           = undef,
) {
  contain zabbix::agent2::purge
  contain zabbix::agent2::install
  contain zabbix::agent2::postinstall
  contain zabbix::agent2::config
  contain zabbix::agent2::service
  contain zabbix::agent2::servicehealth

  Class['zabbix::agent2::purge']
  -> Class['zabbix::agent2::install']
  -> Class['zabbix::agent2::postinstall']
  -> Class['zabbix::agent2::config']
  ~> Class['zabbix::agent2::service']
  ~> Class['zabbix::agent2::servicehealth']
}
