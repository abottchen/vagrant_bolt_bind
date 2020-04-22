#!/bin/bash
if ! grep -q "nameserver\s*${PT_ipaddress}" /etc/resolv.conf; then
  TS=$(date +%s)
  new_resolv_data=$(sed -n "H; $ {x;s/^\n//;s/nameserver .*$/nameserver ${PT_ipaddress}\n&/;p;}" /etc/resolv.conf)
  error=$?
  if [ ${error} -eq 0 ] && [ -n "${new_resolv_data}" ]; then
    cp /etc/resolv.conf /etc/resolv.conf.${TS}
    echo "${new_resolv_data}" > /etc/resolv.conf
  cat << EOF
{
    "nameserver": "${PT_ipaddress}",
    "status": "added",
}
EOF
  else
    cat << EOF
{ "_error": {
    "msg": "Task exited 1:\nUnable to generate new resolv.conf:\n'${new_resolv_data}'",
    "kind": "vagrant_bolt_bind.set_nameserver/task-error",
    "details": { "exitcode": 1 }
}
EOF
    exit 1
  fi
else
  cat << EOF
{
    "nameserver": "${PT_ipaddress}",
    "status": "present",
}
EOF
fi
