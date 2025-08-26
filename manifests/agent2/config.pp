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

  $parameters = {
    pid_file                               => $zabbix::agent2::pid_file,
    log_type                               => $zabbix::agent2::log_type,
    log_file                               => $zabbix::agent2::log_file,
    log_file_size                          => $zabbix::agent2::log_file_size,
    debug_level                            => $zabbix::agent2::debug_level,
    source_ip                              => $zabbix::agent2::source_ip,
    server                                 => $zabbix::agent2::server,
    listen_port                            => $zabbix::agent2::listen_port,
    listen_ip                              => $zabbix::agent2::listen_ip,
    status_port                            => $zabbix::agent2::status_port,
    server_active                          => $zabbix::agent2::server_active,
    hostname                               => $zabbix::agent2::hostname,
    hostname_item                          => $zabbix::agent2::hostname_item,
    host_metadata                          => $zabbix::agent2::host_metadata,
    host_metadata_item                     => $zabbix::agent2::host_metadata_item,
    host_interface                         => $zabbix::agent2::host_interface,
    host_interface_item                    => $zabbix::agent2::host_interface_item,
    refresh_active_checks                  => $zabbix::agent2::refresh_active_checks,
    buffer_send                            => $zabbix::agent2::buffer_send,
    buffer_size                            => $zabbix::agent2::buffer_size,
    enable_persistent_buffer               => $zabbix::agent2::enable_persistent_buffer,
    persistent_buffer_period               => $zabbix::agent2::persistent_buffer_period,
    persistent_buffer_file                 => $zabbix::agent2::persistent_buffer_file,
    alias                                  => $zabbix::agent2::alias,
    timeout                                => $zabbix::agent2::timeout,
    zabbix_agent2_d                        => $zabbix::agent2::zabbix_agent2_d,
    plugin_timeout                         => $zabbix::agent2::plugin_timeout,
    plugin_socket                          => $zabbix::agent2::plugin_socket,
    unsafe_user_parameters                 => $zabbix::agent2::unsafe_user_parameters,
    user_parameter                         => $zabbix::agent2::user_parameter,
    user_parameter_dir                     => $zabbix::agent2::user_parameter_dir,
    control_socket                         => $zabbix::agent2::control_socket,
    tls_connect                            => $zabbix::agent2::tls_connect,
    tls_accept                             => $zabbix::agent2::tls_accept,
    tls_ca_file                            => $zabbix::agent2::tls_ca_file,
    tls_crl_file                           => $zabbix::agent2::tls_crl_file,
    tls_server_cert_issuer                 => $zabbix::agent2::tls_server_cert_issuer,
    tls_server_cert_subject                => $zabbix::agent2::tls_server_cert_subject,
    tls_cert_file                          => $zabbix::agent2::tls_cert_file,
    tls_key_file                           => $zabbix::agent2::tls_key_file,
    tls_psk_identity                       => $zabbix::agent2::tls_psk_identity,
    tls_psk_file                           => $zabbix::agent2::tls_psk_file,
    plugins                                => $zabbix::agent2::plugins,
    plugins_log_max_lines_per_second       => $zabbix::agent2::plugins_log_max_lines_per_second,
    allow_key                              => $zabbix::agent2::allow_key,
    deny_key                               => $zabbix::agent2::deny_key,
    plugins_system_run_log_remote_commands => $zabbix::agent2::plugins_system_run_log_remote_commands,
    force_active_checks_on_start           => $zabbix::agent2::force_active_checks_on_start,
    plugins_d                              => $zabbix::agent2::plugins_d,
  }

  file { $zabbix::agent2::zabbix_agent2_conf:
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp($zabbix::agent2::zabbix_agent2_conf_epp, $parameters),
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
