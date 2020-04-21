plan vagrant_bolt_bind::install_docker(
  TargetSpec $targets,
) {
  $targets.apply_prep

  apply($targets) {
    include docker

    docker::run { 'bind':
      image   => 'sameersbn/bind:9.11.3-20190706',
      ports   => ['53:53/tcp','53:53/udp','10000:10000'],
      volumes => [
                         '/srv/docker/bind:/data', 
                        ],
      pull_on_start    => true,
    }
  }

#  $result = run_task('vagrant_bolt_gitlab::waitfordocker', $targets)
}
