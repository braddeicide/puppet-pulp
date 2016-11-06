# Set up the pulp database
class pulp::database {
  if $pulp::manage_db {
    exec { "Mongo_pid":
      command => "ln /var/run/mongodb/mongod.pid /var/run/mongodb/mongodb.pid",
      path    => "/usr/local/bin:/bin",
      creates => "/var/run/mongodb/mongod.pid",
      before  => Service['mongodb'],
    }

    class { '::mongodb::server': }
  
    Service['mongodb'] -> Service['pulp_celerybeat']
    Service['mongodb'] -> Service['pulp_workers']
    Service['mongodb'] -> Service['pulp_resource_manager']
    Service['mongodb'] -> Service['pulp_streamer']
    Service['mongodb'] -> Exec['migrate_pulp_db']
  }
  exec { 'migrate_pulp_db':
    command   => 'pulp-manage-db && touch /var/lib/pulp/init.flag',
    path      => '/bin:/usr/bin',
    logoutput => 'on_failure',
    user      => 'apache',
    creates   => '/var/lib/pulp/init.flag',
    require   => File['/etc/pulp/server.conf'],
    timeout   => $pulp::migrate_db_timeout,
  }

  Class['pulp::install'] ~> Exec['migrate_pulp_db'] ~> Class['pulp::service']
  Class['pulp::config'] ~> Exec['migrate_pulp_db'] ~> Class['pulp::service']
}
