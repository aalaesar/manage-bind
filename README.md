Work in progress
# Ansible Role: manage-bind
Install and manage your bind9 server on Debian/Ubuntu servers.
Use YAML syntax/files to configure Bind options, zones, etc.

## Requirements
Ansible 2.0 (Ansible 2.0.2+ introduced issue #3)

Note that this role requires root access, so either run it in a playbook with a global `become: yes`, or invoke the role in your playbook like:
```YAML
- hosts: dnsserver
  roles:
    - role: aalaesar.manage-bind
      become: yes
```
## Role Variables
## Bind Options

## Defining A zone.
A Bind zone is defined in two location:
- its **configuration** in Bind
- its **content** of ressource records located somewhere


### Zone configuration
A zone is an element of the list named **'zones'**.
**'zones'** is defined in the role call .
```YAML
- hosts: dnsserver
  roles:
    - role: aalaesar.manage-bind
      become: yes
      zones:
        - ... # zone 1 
        - ... # zone 2
```
One zone is defined with a various number of attributes/statements
Some of thoses statements override the bind options for the zone only
```YAML
zones:
  - name: example.com # Mandatory. The domain's name
    type: master # Mandatory. The type of the zone : master|slave|forward|stub
    

```
### Zone Records
A **zone's** Ressource Records (RR) are defined in mapping named **'records'**

**'records'** can be declared inside the main playbook as a zone's sub element:
```YAML
zones: 
    - name: example.com
      records:
        SOA: ...
        NS: ...
        ... # etc
```

Or declared in an YAML file included using the __yamlfile__ record:
```YAML
zones: 
    - name: example.com
      yamlfile: "./files/example.com.yml
```

**records** must be top level in the yaml file:
```YAML
---
records:
  SOA: ...
  NS: ...
  ... # etc
```

**'records'** in yamlfile has precedence over **'records'** defined in the playbook.

**manage-bind** uses bind's tools **named-checkconf** and **named-checkzone** for configuration and zone validation.
However, thoses tools are limited to **syntax** and **light coherence** verification. this role do not provide advanced validation method
###### Main mapping under **records** :

| RR | Type | Mandatory | Description |
| :------------ | :---: | :-----: | :---------- |
| **ttl** | string | [ ] | Global time to leave for each entry in the zone file |
| **SOA** | Table | [x] | Start of authority. most critical RR. See *SOA details*. |
| **NS** | List | [x] | zone name servers : list of host declared as name servers for this zone. |
| **A** | mapping IP: host/list | [ ] | most common RR for mapping host and IPv4. |
| **AAAA** | mapping IPv6: host/list | [ ] | common RR for mapping host and IPv6. |
| **MX** | mapping host: integer | [ ] | RR for the zone mail servers along with their priority |
| **CNAME** | mapping host: alias/list | [ ] | **Canonical name records** : alias of an host inside or outside of the zone |
| **DNAME** | mapping zone:redirect | [ ] | zone/sub-zone DNS redirection : redirect all labels of a zone to another zone. |
| **TXT** | Table | [ ] | associate some arbirary and unformatted text with a host or other name. Mostly used for SPF and DKIM |
| **SRV** | Table | [ ] | Identifies the host that will support a particular service. **not implemented yet** |
| **PTR** | mapping FQDN: IP | [ ] | Pointer records : opposite of A and AAAA RR. Used in **Reverse Map** zone files to map an IP address (IPv4 or IPv6) to a host name. |

###### Mapping under **SOA** :

| Name | Type | Mandatory | Description |
| :------------ | :---: | :-----: | :---------- |
| serial | Integer | [x] | Serial number for the zone file. **Must always increment** |
| ns | string | [x] | Name server for this zone. must be fully Qualified name with the root '.' |
| email | string | [x] | email of the zon administrator. '@' is susbtitued to '.'. Can be fully qualified or not. |
| refresh | string | [ ] | Same function as zones_config_ttl. Default to zones_config_ttl. |
| retry | string | [ ] | Same role as zones_config_retry. Default to zones_config_retry. |
| expire | string | [ ] | Same role as zones_config_expire. Default to zones_config_expire. |
| negative | string | [ ] | Same role as zones_config_negative. Default to zones_config_negative. |


###### Mapping under **TXT**:

| Name | Type | Mandatory | Description |
| :------------ | :---: | :-----: | :---------- |
| text | String | [x] | The actual record content. Anything between single quotes |
| label | String | [ ] | the Record label. Anything between single quotes |

###### Mapping under **SRV**: not yet implemented

An example zone file can be found in the _test_ folder.

## Dependencies

None.

## Example Playbooks

### Exemple configuration :
- You own the zones example.tld, example.com and example.org
- You have 2 name servers : dnserver1 (11.22.33.44) & dnserver2 (55.66.77.88)
- dnserver1 is master of example.tld and slave of example.com & example.org.
- dnserver2 is master of example.com & example.org and slave of example.tld

### dnserver1's playbook :
```YAML
---
TODO
```
### dnserver2's playbook :
```YAML
---
TODO
```
### YAML file for example.com.yml on dnserver2
```YAML
---
TODO
```

## License
BSD

