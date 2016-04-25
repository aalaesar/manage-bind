# manage-bind


Install and manage bind9 configuration and zones on debian/ubuntu with zones content structured as an YAML files

### Requirements


Ansible 2.0 or later.

### Role Variables
##### Overview
```YAML
# defaults file for bind9
# host configuration 
bind_user:  bind
bind_group: bind
host_dns_srv: self

# log directory
bind_log_dir: /var/log/bind

# Installation configuration
bind_pkg_state: installed
bind_pkgs:
        - bind9
        - dnsutils
bind_service_state: started
bind_service_enabled: yes

# Configs
bind_configs_dir: /etc/bind
bind_config_master_zones: []
bind_config_default_zones: 'yes'
bind_config_master_allow_transfer: []
bind_config_master_forwarders: []
bind_config_slave_zones: []
bind_config_forward_zones: []
bind_option_allow_recursion: []
bind_option_listen_on: any
bind_option_listen_on_v6: any
bind_option_allow_query: []

# Zones files
bind_zones_dir: /var/lib/bind
bind_zones_masters_dir: "masters"
bind_zones_slaves_dir: "slaves"

# Zones default configuration
zones_config_ttl: 38400
zones_config_refresh: 10800
zones_config_retry: 3600
zones_config_expire: 604800
zones_config_minimum: 38400
```
##### Details :
| Variable name | Type | Default | Description |
| :------------ | :---: | :-----: | :---------- |
|`bind_user`| String | bind | User name for system's daemon. |
|`bind_group`| String | bind | Group name for the system's daemon. |
|`host_dns_srv`| String | Self| Specify if the host should search itself for name resolution. |
|`bind_log_dir`| String | /var/log/bind | Directory for Bind logs. |
|`bind_pkg_state`| String | installed | Used for installing or uninstalling the role. Can be states defined in the apt module. |
|`bind_pkgs`| list | { bind9, dnsutils } | List of packages name related to this role. |
|`bind_configs_dir`| String | /etc/bind | Bind config directory in the system. |
|`bind_config_master_zones`| list | _empty_ | List of zones type master you want to implement. |
|	`=>- name`| String | _null_ | The zone name - **mandatory** |
|	`=>  file`| String | ./files/{{zone's name}}.yml | Full path to the yaml file containing the zone configuration. |
|	`=>  allow_transfer`| list of IP | _null_ | Bind will allow transfer of the zone content to thoses hosts. Typically slaves servers. |
|	`=>  allow_recursion`| list of IP | _null_ | Bind will allow recursion query concerning this zone from thoses host (not implemented yet) |
|	`=>  allow_update`| list of IP| _null_ | Bind will allow updates to this zone from thoses hosts. |
|`bind_config_default_zones`| String | 'Yes' | Include default zone from RFC 1912 in bind. |
|`bind_config_master_allow_transfer`| list of IP | _empty_ | Bind will allow transfer of any zone file to thoses hosts. Typically slaves servers. |
|`bind_config_master_forwarders`| list of IP | _empty_ | Bind will forward queries to thoses hosts for resolving other zones (caching & non-authoritative) |
|`bind_config_slave_zones`| list | _empty_ | list of zones type slave you want to implement. |
|	`=>- name`| String | _null_ | The zone name - **mandatory** |
|	`=>  masters`| list of IP | _null_ | The zone's master(s) - **mandatory** |
|`bind_config_forward_zones`| list | _empty_ | list of zones type forward you want to implement. |
|	`=>- name`| String | _null_ | The zone name - **mandatory** |
|	`=>  forward`| String | _null_ | **todo** |
|	`=>  forwarders`| list of IP | _null_ | Bind will forward queries to thoses hosts - **mandatory** |
|`bind_option_allow_recursion`| list of IP | _empty_ | Only allow this list of hosts to make recursives queries. |
|`bind_option_listen_on`| String | Any | The IP address on which BIND will listen for incoming queries using default port (56) |
|`bind_option_listen_on_v6`| String | Any | The IPv6 address on which BIND will listen for incoming queries using default port (56) |
|`bind_option_allow_query`| list of IP | _empty_ | Defines a list of hosts which are allowed to issue queries to the server. Permissive ACL : if empty, all hosts are allowed. |
|`bind_zones_dir`| String | /var/lib/bind | Defines the storage folder for the zone files. |
|`bind_zones_masters_dir`| String | masters | Sub-folder for master zones files. |
|`bind_zones_slaves_dir`| String | slaves | Sub-folder for Slaves zones files. |
|`zones_config_ttl`| Integer | 38400 | Define the default global _time to live_ of ressource records. in seconds. |
|`zones_config_refresh`| Integer | 10800 | Define the default refresh delay for slave/caching servers. in seconds. |
|`zones_config_retry`| Integer | 3600 | Define the default retry delay for slave/caching servers. in seconds. |
|`zones_config_expire`| Integer | 604800 | Define the default zone expiration delay for slave/caching servers. in seconds. |
|`zones_config_minimum`| Integer | 38400 | Define the default minimum delay for slave/caching servers between 2 requests. in seconds. |

### Dependencies

None.

### Example Playbook

###### Exemple configuration :
- You own the zones example.tld, example.com and example.org
- You have 2 name servers : dnserver1 (11.22.33.44) & dnserver2 (55.66.77.88)
- dnserver1 is master of example.tld and slave of example.com & example.org.
- dnserver2 is master of example.com & example.org and slave of example.tld

- dnserver1's playbook :
```YAML
---
- hosts:  dnservers1
  roles:
   - role: bind9
     bind_option_recursion: "yes"
     bind_option_allow_recursion:
      - 127.0.0.1
      - 55.66.77.88
     bind_config_master_zones:
      - name: example.tld
        file: /bind_zones/example.tld.yml
        allow_transfer:
         - 55.66.77.88
      - name: 33.22.11.in-addr.arpa
        file: /bind_zones/33.22.11.in-addr.arpa.yml
     bind_config_slave_zones:
      - name: example.com
        masters:
         - 55.66.77.88
      - name: example.org
        masters:
         - 55.66.77.88
```
dnserver2's playbook :
```YAML
---
- hosts:  dnservers2
  roles:
   - role: bind9
     bind_option_recursion: "yes"
     bind_option_allow_recursion:
      - 127.0.0.1
      - 11.22.33.44
     bind_config_master_zones:
      - name: example.com
        file: /bind_zones/example.com.yml
        allow_transfer:
         - 11.22.33.44
      - name: example.org
        file: /bind_zones/example.org.yml
        allow_transfer:
         - 11.22.33.44
      - name: 77.66.55.in-addr.arpa
        file: /bind_zones/77.66.55.in-addr.arpa.yml
     bind_config_slave_zones:
      - name: example.tld
        masters:
         - 11.22.33.44
```
YAML file for example.com.yml on dnserver1
```YAML
---
zones_file:
 - name: example.com
   SOA:
     serial: 2016041903
     ns: dnserver1.fqdn
     email: admin.example.com
   NS:
     - dnserver1.fqdn.
     - dnserver2.fqdn.
   A:
     11.22.33.44:
       - '@'
       - dnserver1.fqdn.
     55.66.77.88: dnserver2.fqdn.
     12.34.56.78: host1
	 98.76.54.32: mailsrv
   AAAA:
     fe80:cafe:fa:1::1de: '@'
   MX:
     mailsrv: 10
   CNAME:
     ftp: 'host1'
     www: '@'
     webmail: '@'
   TXT:
     - text: '"v=spf1 mx -all"'
     - text: '( "v=DKIM1; k=rsa; t=s; n=core; p=someverylongstringbecausethisisakeyformailsecurity" )  ; ----- DKIM key mail for example.com'
       label: mail._domainkey
```

## License

BSD

