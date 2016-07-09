# manage-bind


Install and manage bind9 configuration and zones ( master, slave and forward types) with zones content structured as an YAML files
Bind is a very rich and powerfull tool, the configuration managed by this role does not cover
all it's specifications but provide enough options for a large number of uses cases.
### Requirements


Ansible 2.0 or later.

### Role Variables

### YAML zone File

**manage-bind** will not check the coherence of your zone records : you must know what you're doing.

A **zone** is defined as a mapping of Ressource Records (RR) and a name.
RR are grouped by type.

###### Main mapping under **zone** :

| RR/name | Type | Mandatory | Description |
| :------------ | :---: | :-----: | :---------- |
| **name** | string | [x] | the zone name, without the root |
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
| **URI** | string | [ ] | Alternative to the SRV RR. return a single string containing all informations for a particular service. **not implemented yet** |
| **PTR** | mapping FQDN: IP | [ ] | Pointer records : opposite of A and AAAA RR. Used in **Reverse Map** zone files to map an IP address (IPv4 or IPv6) to a host name. |
| **KEY** | _null_ | [ ] | Public Key Record. **not implemented yet** |
| **DNSKEY** | _null_ | [ ] | Part of the **DNSSEC** standard. Contain the public key used in zone signing operations. **not implemented yet** |
| **DS** | _null_ | [ ] | Part of the **DNSSEC** standard. Delegated Signer RR. **not implemented yet** | 
| **RRSIG** | _null_ | [ ] | Signed RRset. Part of the **DNSSEC** standard.**not implemented yet** |
| **NSEC** | _null_ | [ ] | Next Secure record. Part of the **DNSSEC** standard. Seed for providing proof of non-existence of a name. **not implemented yet** |

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

### Dependencies

None.

### Example Playbooks

###### Exemple configuration :
- You own the zones example.tld, example.com and example.org
- You have 2 name servers : dnserver1 (11.22.33.44) & dnserver2 (55.66.77.88)
- dnserver1 is master of example.tld and slave of example.com & example.org.
- dnserver2 is master of example.com & example.org and slave of example.tld

###### dnserver1's playbook :
```YAML
---
TODO
```
###### dnserver2's playbook :
```YAML
---
TODO
```
###### YAML file for example.com.yml on dnserver2
```YAML
---
TODO
```

## License

BSD

