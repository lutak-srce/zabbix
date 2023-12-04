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
  $zbx_monitor_user        = 'zbx_monitor',
  $zbx_monitor_password,
) inherits zabbix::agent {

  # Ensure git is installed
  package { 'git':
    ensure => installed,
  }

  # Set a global default path for all exec resources
  Exec {
    path => ['/usr/bin'],
  }

  # PostgreSQL user and grant
  exec { 'add_${zbx_monitor_user}_user':
    command => "sudo -u postgres psql -c \"CREATE USER ${zbx_monitor_user} WITH PASSWORD '${zbx_monitor_password}';\"",
    unless  => "sudo -u postgres psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${zbx_monitor_user}';\"",
  }

  exec { 'zbx_grant_monitor':
    command => "sudo -u postgres psql -c 'GRANT pg_monitor TO ${zbx_monitor_user};'",
    unless  => "sudo -u postgres psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${zbx_monitor_user}' AND rolsuper IS FALSE;\"",
    require => Exec['add_${zbx_monitor_user}_user'],
  }

  # Cron job for grant connect
  file { '/etc/cron.d/zbx_grant_connect':
    content => "* */12 * * * root /usr/bin/psql -t -c \"SELECT format('GRANT CONNECT ON DATABASE %I TO ${zbx_monitor_user};', datname) FROM pg_database\" | /usr/bin/psql -U postgres\n",
    require => Exec['add_${zbx_monitor_user}_user'],
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
      creates => "${tmp_dir}/.git",
      onlyif  => "test -z \"$(ls -A ${tmp_dir})\"",
    }

    # Configure sparse checkout
    exec { 'config-sparse-checkout':
      command     => "git -C ${tmp_dir} config core.sparseCheckout true",
      onlyif      => "test -d ${tmp_dir}/.git",
      refreshonly => true,
      subscribe   => Exec["git-clone"],
    }
    
    # Define the sparse-checkout file
    exec { 'define-sparse-checkout':
      command => "echo ${templates_path}/ > ${tmp_dir}/.git/info/sparse-checkout",
      creates => "${tmp_dir}/.git/info/sparse-checkout",
      require => Exec['config-sparse-checkout'],
    }
    
    # Checkout the desired branch and pull changes
    exec { 'git-pull':
      command     => "git -C ${tmp_dir} checkout ${repo_branch}; git -C ${tmp_dir} pull",
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
