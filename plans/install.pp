plan vagrant_bolt_bind::install (
  TargetSpec $targets) {

 run_plan('vagrant_bolt_bind::install_supporting_files', $targets) 
 run_plan('vagrant_bolt_bind::install_docker', $targets) 
}
