#!/bin/bash -x
BIND_PATH="/srv/docker/bind/bind/lib"

IFS='.' read -ra ip_addr_arr <<< "$PT_ipaddress"

#check if there is a forward file out there
domain=${PT_hostname:$(expr index "${PT_hostname}" .)}
forward_file="${BIND_PATH}/${domain}.hosts"
if [ ! -f "${forward_file}" ]; then
  cat << EOF
{ "_error": {
    "msg": "Task exited 1:\nNo forward resolution file for '${domain}'",
    "kind": "vagrant_bolt_bind.add_host/task-error",
    "details": { "exitcode": 1 }
}
EOF
  exit 1
fi

#check if there is a reverse file out there
for octects in {1..3}; do
  subnet=$(IFS=. ; echo "${ip_addr_arr[*]:0:${octects}}")
  reverse_file="${BIND_PATH}/${subnet}.rev"
  if [ -f "${reverse_file}" ]; then
    break
  fi
  reverse_file=""
done

if [ -z ${reverse_file} ]; then
  cat << EOF
{ "_error": {
    "msg": "Task exited 1:\nNo reverse resolution file for '${PT_ipaddress}'",
    "kind": "vagrant_bolt_bind.add_host/task-error",
    "details": { "exitcode": 1 }
}
EOF
  exit 1
fi

reversed_ip_arr=()
for ((i=${#ip_addr_arr[*]}-1; i>=${octects}; i--)); do
  reversed_ip_arr+=( "${ip_addr_arr[$i]}" )
done
reversed_ip=$(IFS=. ; echo "${reversed_ip_arr[*]}")

new_forward_line="${PT_hostname}. IN A ${PT_ipaddress}"
new_reverse_line="${reversed_ip} IN PTR ${PT_hostname}."

#check the files to see if there is already an entry for the hostname or ip
if ! existing_line=$(grep "${new_forward_line}" "${forward_file}"); then
  echo "${new_forward_line}" >> "${forward_file}"
fi

if [ ! -z "${existing_line}" ]; then
  cat << EOF
{ "_error": {
    "msg": "Task exited 1:\nMatching A record already present:\n'${existing_line}'",
    "kind": "vagrant_bolt_bind.add_host/task-error",
    "details": { "exitcode": 0 }
}
EOF
  exit 0
fi

if ! existing_line=$(grep -q "${new_reverse_line}" "${reverse_file}"); then
  echo "${new_reverse_line}" >> "${reverse_file}"
fi

if [ ! -z "${existing_line}" ]; then
  cat << EOF
{ "_error": {
    "msg": "Task exited 1:\nMatching PTR record already present:\n'${existing_line}'",
    "kind": "vagrant_bolt_bind.add_host/task-error",
    "details": { "exitcode": 0 }
}
EOF
  exit 0
fi

# restart the service
systemctl restart docker-bind

cat << EOF
{
    "hostname": "${PT_hostname}",
    "ipaddress": "${PT_ipaddress}",
    "status": "success",
}
EOF
