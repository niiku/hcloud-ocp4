
%{ for index, hostname in split(",", nodes) ~}
ssh -o "StrictHostKeyChecking=no" root@${hostname} /bin/bash -c "/sbin/reboot" -i ${private_key_path}
%{ endfor ~}