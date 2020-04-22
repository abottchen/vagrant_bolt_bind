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
    if $facts['ec2_metadata'] {
        $ip = $facts['ec2_metadata']['public-ipv4']
    } else {
        $ip = $facts['networking']['ip']
    }

    $ip_arr = split($ip, "[.]")
    $reversed_ip = join($ip_arr[1,3].reverse_each.map |$i| { $i }, '.')
    $add_localhost = $facts['fqdn'] =~ /puppetdebug.vlan$/ and $ip =~ /^10/
    
    file{'/srv/docker/bind/bind/lib/10.rev':
      ensure => file,
      content => epp('vagrant_bolt_bind/10.rev', 'reversed_ip' => $reversed_ip, 'add_localhost' => $add_localhost),
    }
    file{'/srv/docker/bind/bind/lib/puppetdebug.vlan.hosts':
      ensure => file,
      content => epp('vagrant_bolt_bind/puppetdebug.vlan.hosts', 'add_localhost' => $add_localhost, 'ip' => $ip),
    }
  }
}
