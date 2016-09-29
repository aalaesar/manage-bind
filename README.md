Work in progress
# Ansible Role: manage-bind
Install and manage your bind9 server on Debian/Ubuntu servers.
Use YAML syntax/files to configure Bind options, zones, etc.

## Requirements
Ansible 2.0 (Ansible 2.0.2+ introduced issue #3)

Note that this role requires root access, so either run it in a playbook with a global `become: yes`, or invoke the role in your playbook like:
> playbook.yml:
```YAML
- hosts: dnsserver
  roles:
    - role: aalaesar.manage-bind
      become: yes
```

## Role Variables


## Bind's configuration contexts
Bind uses **clause contexts** to allow precise configuration.
- A context is a **set** of statements.
- Contexts can **includes** (parent) and **be included** (child) by other contexts:
 - **Options** is the _largest_ context that include all others.
 - **zone** is the _smallest_ context. It can't include any other context.
- Some statements are common to 2 or more clause contexts. In this case, inheritance rules apply:
 - A context implicitely inherit of it's parent's statements.
 - If defined, a context can override its parent's statement and pass on the new value to its child(ren). 
- Some statements are clause specific and cannot be inherited or passed on. 

manage-bind is constructed to use this functionnality.
It support _options_ and _zone_ contexts.
## Bind Options
### Defining options for bind
When calling **manage-bind**, you can pass bind's main options as a mapping inside your playbook or in a external YAML file.

Options defined in an external file have precedence over options defined in the playbook but both have precedence over the default options.

The list of all options statements availables is in **./tests/bind_options.yml**
> playbook.yml:
```YAML
- hosts: dnsserver
  roles:
    - role: aalaesar.manage-bind
      become: yes
      options_file: ./files/option.yml # the role will load thoses options
      options:
        statement1: ...
        statement2: ...
```

### Changing the role's default options :
The role come with some default options for bind.
They are defined in **./defaults/default_options.yml**
You may use this file to share a common policy over your servers and override specific options easily
### _Caution_ when defining options 
- Escape special char like @ with quotes
- Some statements requires "yes|no" value: Escape **yes** and **no** with quotes as ansible parses them as boolean.

## Defining a zone.
A Bind zone is defined in two locations:
- its **configuration** in named.conf files.
- its **data** of ressource records located in a file 

### _Caution_ when defining a zone
- **manage-bind** uses bind's tools **named-checkconf** and **named-checkzone** for configuration and zone validation.
However, thoses tools are limited to **syntax** and **light coherence** verification. This role do not provide advanced validation methods.
- Escape special char like @ with quotes
- Some statements requires "yes|no" value: Escape **yes** and **no** with quotes as ansible parses them as boolean.
### Zone configuration
A zone is an element of the list named **'zones'**.
**'zones'** is defined in the role call and is mandatory.
> playbook.yml:
```YAML
- hosts: dnsserver
  roles:
    - role: aalaesar.manage-bind
      become: yes
      zones:
        - ... # zone 1 
        - ... # zone 2
```
A zone configuration is defined with a various number of attributes/statements:
- Some statements are specific to zones types
- Other are common with bind's options and override them for only this zone. (this is a bind feature)
> playbook.yml:
```YAML
zones:
  - name: example.com # Mandatory. The domain's name
    type: master # Mandatory. The type of the zone : master|slave|forward|stub
    recursion: "no" # statement overriding global option recursion for this zone.
    ... # etc
```
The list of all zone's statements availables is in **./tests/zone_statements.md**

### Zone Data (Records)
In summary : A **zone's** data is defined in a mapping named **'records'**

**'records'** can be declared _inside the main playbook_ as a zone's attribute,

or declared in an YAML file using the **_yamlfile_** attribute.

**Data** defined in yamlfile has precedence over **data** defined in the playbook.
> playbook.yml:
```YAML
zones: 
  - name: example.com
    records:
      SOA: ...
      NS: ...
      ... # etc
    ... # etc
  - name: test.tld
    yamlfile: "./files/test.tld.yml
    records: # will be ignored in this zone
      SOA: ...
      NS: ...
    ... # etc
```
In the yaml file, **records** must be top level:
> ./files/test.tld.yml:
```YAML
---
records:
  SOA: ...
  NS: ...
  ... # etc
```
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
