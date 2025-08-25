#
# Class: zabbix::agent2
#
# This module manages zabbix agent variant 2
#
class zabbix::agent2 (
  String               $package_name           = 'zabbix-agent2',
  String               $package_ensure         = present,
  String               $legacy_agent           = 'zabbix-agent',
  String               $legacy_agent_ensure    = purged,
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
  Stdlib::Absolutepath $zabbix_agent2_d        = '/etc/zabbix/zabbix_agent2.d',
  Stdlib::Absolutepath $zabbix_agent2_conf     = '/etc/zabbix/zabbix_agent2.conf',
  String               $zabbix_agent2_conf_epp = 'zabbix/agent2/zabbix_agent2.conf.epp',
  Stdlib::Absolutepath $plugins_d              = '/etc/zabbix/zabbix_agent2.d/plugins.d',
  # General parameters
  Optional[Stdlib::Absolutepath]              $pid_file      = '/var/run/zabbix/zabbix_agent2.pid',
  Optional[Enum['system', 'file', 'console']] $log_type      = undef,
  Optional[Stdlib::Absolutepath]              $log_file      = '/var/log/zabbix/zabbix_agent2.log',
  Optional[Integer[0,1024]]                   $log_file_size = 0,
  Optional[Integer[0,5]]                      $debug_level   = undef,
  Optional[Stdlib::IP::Address]               $source_ip     = undef,
  # Passive checks related
  Optional[Variant[Stdlib::Host, Array[Stdlib::Host,1]]]               $server      = '127.0.0.1',
  Optional[Integer[1024,32767]]                                        $listen_port = undef,
  Optional[Variant[Stdlib::IP::Address, Array[Stdlib::IP::Address,1]]] $listen_ip   = undef,
  Optional[Integer[1024,32767]]                                        $status_port = undef,
  # Active checks related
  Optional[Variant[String[1], Array[String[1]]]]         $server_active            = '127.0.0.1',
  Optional[Variant[String[1], Array[String[1]]]]         $hostname                 = $facts['networking']['fqdn'],
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
  Optional[Array[String]]        $alias          = undef,
  Optional[Integer[1,30]]        $timeout        = undef,
  Optional[Integer[1,30]]        $plugin_timeout = undef,
  Optional[Stdlib::Absolutepath] $plugin_socket  = '/run/zabbix/agent.plugin.sock',
  # User-defined monitored parameters
  Optional[Integer[0,1]]         $unsafe_user_parameters = undef,
  Optional[Array[Struct[{
    key           => String[1],
    shell_command => String[1],
  }]]]                           $user_parameter         = undef,
  Optional[Stdlib::Absolutepath] $user_parameter_dir     = undef,
  Optional[Stdlib::Absolutepath] $control_socket         = '/run/zabbix/agent.sock',
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
  package { $legacy_agent:
    ensure => $legacy_agent_ensure,
    before => Package[$package_name],
  }

  package { $package_name:
    ensure => $package_ensure,
  }

  service { $service_name:
    ensure  => $service_ensure,
    enable  => $service_enable,
  }

  file { $zabbix_agent2_d:
    ensure  => directory,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $dir_mode,
    recurse => $file_recurse,
    purge   => $file_purge,
    force   => $file_force,
    require => Package[$package_name],
  }

  $parameters = {
    pid_file                               => $pid_file,
    log_type                               => $log_type,
    log_file                               => $log_file,
    log_file_size                          => $log_file_size,
    debug_level                            => $debug_level,
    source_ip                              => $source_ip,
    server                                 => $server,
    listen_port                            => $listen_port,
    listen_ip                              => $listen_ip,
    status_port                            => $status_port,
    server_active                          => $server_active,
    hostname                               => $hostname,
    hostname_item                          => $hostname_item,
    host_metadata                          => $host_metadata,
    host_metadata_item                     => $host_metadata_item,
    host_interface                         => $host_interface,
    host_interface_item                    => $host_interface_item,
    refresh_active_checks                  => $refresh_active_checks,
    buffer_send                            => $buffer_send,
    buffer_size                            => $buffer_size,
    enable_persistent_buffer               => $enable_persistent_buffer,
    persistent_buffer_period               => $persistent_buffer_period,
    persistent_buffer_file                 => $persistent_buffer_file,
    alias                                  => $alias,
    timeout                                => $timeout,
    zabbix_agent2_d                        => $zabbix_agent2_d,
    plugin_timeout                         => $plugin_timeout,
    plugin_socket                          => $plugin_socket,
    unsafe_user_parameters                 => $unsafe_user_parameters,
    user_parameter                         => $user_parameter,
    user_parameter_dir                     => $user_parameter_dir,
    control_socket                         => $control_socket,
    tls_connect                            => $tls_connect,
    tls_accept                             => $tls_accept,
    tls_ca_file                            => $tls_ca_file,
    tls_crl_file                           => $tls_crl_file,
    tls_server_cert_issuer                 => $tls_server_cert_issuer,
    tls_server_cert_subject                => $tls_server_cert_subject,
    tls_cert_file                          => $tls_cert_file,
    tls_key_file                           => $tls_key_file,
    tls_psk_identity                       => $tls_psk_identity,
    tls_psk_file                           => $tls_psk_file,
    plugins                                => $plugins,
    plugins_log_max_lines_per_second       => $plugins_log_max_lines_per_second,
    allow_key                              => $allow_key,
    deny_key                               => $deny_key,
    plugins_system_run_log_remote_commands => $plugins_system_run_log_remote_commands,
    force_active_checks_on_start           => $force_active_checks_on_start,
    plugins_d                              => $plugins_d,
  }

  file { $zabbix_agent2_conf:
    ensure  => $file_ensure,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    content => epp($zabbix_agent2_conf_epp, $parameters),
    notify  => Service[$service_name],
  }

  file { $plugins_d:
    ensure  => directory,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $dir_mode,
    recurse => $file_recurse,
    purge   => $file_purge,
    force   => $file_force,
  }

  # enable zabbix plugins to run sudo
  ::sudoers::requiretty { 'zabbix_notty':
    requiretty => false,
    user       => 'zabbix',
    comment    => 'Allow user zabbix to run sudo without tty',
  }

  user { 'zabbix':
    ensure  => present,
    require => Package[$package_name],
  }

  group { 'zabbix':
    ensure  => present,
    require => Package[$package_name],
  }

  # if log_type is 'file' log_file must be specified
  if $log_type == 'file' {
    unless $log_file {
      fail('log_file must be specified when log_type is set to file')
    }
  }

  # include config files of inbuilt or dependant plugins
  include zabbix::agent2::plugin::ceph
  include zabbix::agent2::plugin::docker
  include zabbix::agent2::plugin::memcached
  include zabbix::agent2::plugin::modbus
  include zabbix::agent2::plugin::mongodb
  include zabbix::agent2::plugin::mqtt
  include zabbix::agent2::plugin::mysql
  include zabbix::agent2::plugin::oracle
  include zabbix::agent2::plugin::postgresql
  include zabbix::agent2::plugin::redis
  include zabbix::agent2::plugin::smart
}
