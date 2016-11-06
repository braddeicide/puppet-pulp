# Pulp Admin Configuration
class pulp::admin::config {
  file { '/etc/pulp/admin/admin.conf':
    ensure  => 'file',
    content => template('pulp/admin.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if $pulp::admin::enable_puppet {
    file { '/etc/pulp/admin/conf.d/puppet.conf':
      ensure  => 'file',
      content => template('pulp/admin_puppet.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  }

  file {"${facts['home']}/.pulp/": 
      ensure  => 'directory',
      owner   => $facts['identity']['user'],
      group   => $facts['identity']['user'],
      mode    => '0700',
  }
  if $pulp::admin::admin_auto_login {
    file {"${facts['home']}/.pulp/admin.conf":
      ensure  => 'file',
      content => template('pulp/user_admin.conf.erb'),
      owner   => $facts['identity']['user'],
      group   => $facts['identity']['user'],
      mode    => '0600',
      require => File["${facts['home']}/.pulp/"]
    }
  }
}
