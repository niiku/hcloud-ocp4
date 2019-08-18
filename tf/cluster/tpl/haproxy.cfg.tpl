# Global settings
#---------------------------------------------------------------------
global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen stats
    bind :9000
    mode http
    stats enable
    stats uri /
    monitor-uri /healthz


frontend openshift-api-server
    bind *:6443
    default_backend openshift-api-server
    mode tcp
    option tcplog

backend openshift-api-server
    balance source
    mode tcp
    server bootstrap ${bootstrap_hostname}.sh:6443 check
%{ for index, hostname in split(",", master_hostnames) ~}
    server master${index} ${hostname}:6443 check
%{ endfor ~}

frontend machine-config-server
    bind *:22623
    default_backend machine-config-server
    mode tcp
    option tcplog

backend machine-config-server
    balance source
    mode tcp
    server bootstrap ${bootstrap_hostname}.sh:22623 check
%{ for index, hostname in split(",", master_hostnames) ~}
    server master${index} ${hostname}:22623 check
%{ endfor ~}

frontend ingress-http
    bind *:80
    default_backend ingress-http
    mode tcp
    option tcplog

backend ingress-http
    balance source
    mode tcp
%{ for index, hostname in split(",", worker_hostnames) ~}
    server worker${index} ${hostname}:80 check
%{ endfor ~}


frontend ingress-https
    bind *:443
    default_backend ingress-https
    mode tcp
    option tcplog

backend ingress-https
    balance source
    mode tcp
%{ for index, hostname in split(",", worker_hostnames) ~}
    server worker${index} ${hostname}:443 check
%{ endfor ~}