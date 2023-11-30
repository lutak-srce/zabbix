#
# = Class: zabbix::agent::postgresql
#
# This module installs zabbix postgresql sensor
#
class zabbix::agent::postgres (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $zabbix_dir              = '/var/lib/zabbix',
  $tmp_dir                 = '/tmp/postgresql',
  $repo_url                = 'https://git.zabbix.com/scm/zbx/zabbix.git',
  $repo_branch             = 'release/6.0',
  $templates_path          = 'templates/db/postgresql',
) inherits zabbix::agent {

  # Ensure git is installed
  package { 'git':
    ensure => installed,
  }

  # Ensure the directory exists
  file { $zabbix_dir:
    ensure => directory,
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0770',
    require => Package['zabbix-agent'],
  }

  # Check if the desired directory is empty
  $is_empty = exec { "check-${zabbix_dir}-empty":
    command     => "test -z \"\$(ls -A ${zabbix_dir})\"",
    path        => ['/bin', '/usr/bin'],
    onlyif      => "test -d ${zabbix_dir}",
    logoutput   => true,
    refreshonly => true,
    subscribe   => File["${zabbix_dir}"],
  }

  # Only proceed if the directory is empty
  if $is_empty {

    # Clone the repository using git commands
    exec { 'git-clone':
      command => "git clone --depth 1 --branch ${repo_branch} ${repo_url} --single-branch ${tmp_dir}",
      path    => '/usr/bin',
      creates => "${tmp_dir}/.git",
      onlyif  => "test -z \"$(ls -A ${tmp_dir})\"",
    }

    # Configure sparse checkout
    exec { 'config-sparse-checkout':
      command     => "git -C ${tmp_dir} config core.sparseCheckout true",
      path        => '/usr/bin',
      onlyif      => "test -d ${tmp_dir}/.git",
      refreshonly => true,
      subscribe   => Exec["git-clone"],
    }
    
    # Define the sparse-checkout file
    exec { 'define-sparse-checkout':
      command => "echo ${templates_path}/ > ${tmp_dir}/.git/info/sparse-checkout",
      path    => '/usr/bin',
      creates => "${tmp_dir}/.git/info/sparse-checkout",
      require => Exec['config-sparse-checkout'],
    }
    
    # Checkout the desired branch and pull changes
    exec { 'git-pull':
      command     => "git -C ${tmp_dir} checkout ${repo_branch}; git -C ${tmp_dir} pull",
      path        => '/usr/bin',
      require     => Exec['define-sparse-checkout'],
      refreshonly => true,
      subscribe   => Exec["git-clone"],
    }

    # Copy config files to the desired folder
    file { "${zabbix_dir}/postgresql":
      ensure  => directory,
      recurse => true,
      source  => "${tmp_dir}/${templates_path}/postgresql",
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0770',
      require => Exec["git-clone"],
    }

    file { "${dir_zabbix_agentd_confd}/postgresql.conf":
      ensure  => file,
      source  => "${tmp_dir}/${templates_path}/template_db_postgresql.conf",
      require => Exec["git-clone"],
    }
  }
}
