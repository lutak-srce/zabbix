#
# = Class: zabbix::agent::phpfpm
#
# This module installs Zabbix php-fpm sensor
#
class zabbix::agent::phpfpm (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $php_fpm_sock            = undef,
) inherits zabbix::agent {

  case $facts['os']['family'] {
    default: {
      $cgi_fcgi = 'fcgi'
      if $php_fpm_sock == undef {
        $_php_fpm_sock = '127.0.0.1:9000'
      }
      else {
        $_php_fpm_sock = $php_fpm_sock
      }
    }
    /(RedHat|redhat|amazon)/: {
      $cgi_fcgi = 'fcgi'
      if $php_fpm_sock == undef {
        if $::facts['os']['release']['major'] == '8' {
          $_php_fpm_sock = '/run/php-fpm/www.sock'
        }
        else {
          $_php_fpm_sock = '127.0.0.1:9000'
        }
      }
      else {
        $_php_fpm_sock = $php_fpm_sock
      }
      User <| title == zabbix |> { groups +> 'apache' }
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $cgi_fcgi = 'libfcgi-bin'
      if $php_fpm_sock == undef {
        if $::facts['os']['release']['major'] == '10' {
          $_php_fpm_sock = '/run/php/php7.3-fpm.sock'
        }
        if $::facts['os']['release']['major'] == '11' {
          $_php_fpm_sock = '/run/php/php7.4-fpm.sock'
        }
        else {
          $_php_fpm_sock = '/run/php/php7.0-fpm.sock'
        }
      }
      else {
        $_php_fpm_sock = $php_fpm_sock
      }
      User <| title == zabbix |> { groups +> 'www-data' }
    }
  }

  package { 'cgi-fcgi':
    ensure => present,
    name   => $cgi_fcgi,
  }

  file { "${conf_dir}/php-fpm.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/php-fpm.conf.erb'),
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/php-fpm.sh"],
      Package['cgi-fcgi'],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/php-fpm.sh" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('zabbix/agent/php-fpm.sh.erb'),
  }

}
