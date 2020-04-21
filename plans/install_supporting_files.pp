plan vagrant_bolt_bind::install_supporting_files(
  TargetSpec $targets,
) {
  $targets.apply_prep
  apply($targets) {
    file{"/tmp/bind_files.tar.gz":
      ensure => file,
      source => "puppet:///modules/vagrant_bolt_bind/bind_files.tar.gz",
    }
  }

  run_task('vagrant_bolt_bind::extract_supporting_files', $targets)

  apply($targets) {
    $ip_arr = split($facts['networking']['ip'], "[.]")
    $reversed_ip = join($ip_arr[1,3].reverse_each.map |$i| { $i }, '.')
    $add_localhost = $facts['fqdn'] =~ /puppetdebug.vlan$/
    
    file{'/srv/docker/bind/bind/lib/10.rev':
      ensure => file,
      content => epp('vagrant_bolt_bind/10.rev', 'reversed_ip' => $reversed_ip, 'add_localhost' => $add_localhost),
    }
    file{'/srv/docker/bind/bind/lib/puppetdebug.vlan.hosts':
      ensure => file,
      content => epp('vagrant_bolt_bind/puppetdebug.vlan.hosts', 'add_localhost' => $add_localhost),
    }
  }
}
