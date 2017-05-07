Work in progress
# Ansible Role: manage-bind
 This role is built as an abstraction layer to configure bind and create DNS zones using YAML syntax.
- [x] Install and manage your bind9 server on Debian/Ubuntu servers.
- [x] Use YAML syntax/files to configure Bind options, zones, etc.

## Requirements
Ansible 2.0 (Ansible 2.0.2+ introduced issue #3)
or Ansible 2.2+
**Note:** this role requires root access, so either run it in a playbook with a global `become: yes`, or invoke the role in your playbook like:
> playbook.yml:
```
- hosts: dnsserver
  roles:
    - role: aalaesar.manage-bind
      become: yes
```

## Role Variables

## Configuring Bind
### Introduction to Bind's configuration
Bind uses **clause's statements inheritance** mechanism to allow precise configuration.
- A **_clause_** is a class with its own **set** of statements.
  - They can have specific or common statements.
  - A clause defined inside another clause will implicitly inherit its mother's common statements.
- A **_statement_** is a clause's property.
  - It describes the server's behavior on how to perform a task, whether, when, etc.
  - It may be explicitly or implicitly defined.
- ***Some inheritance rules***:
 - **Options** is the _top_ clause that include all others.
 - **zone** is the _lowest_ clause. It can't have any child. It also contains **zone records**.
 - a clause can override its parent's statement and pass on the new value to its child(ren) by redefining explicitly the statement.
> Here is an ASCII example of this rules:
```
|##########|  
|  zone1   |  |#########|
|==========|  |  zone2  |
|statement1|  |=========|
|  =john   |  |         |
|##########|  |#########|
     /\            /\
     ||            ||
|#######################|   |##############|   |##############|
|         view1         |   |   zone3      |   |    zone4     |
|=======================|   |==============|   |              |
|  statement2=kangaroo  |   |statement1=bar|   |##############|
|#######################|   |##############|          /\
           /\                     /\                  ||
           ||                     ||                  ||
|#############################################################|
|                          Options                            |
|=============================================================|
|                       statement1=foo                        |
|                      statement2=koala                       |
|#############################################################|
Final result:
According statement1 & statement2 are common to all clauses
zone1: statement1=john, statement2=kangaroo
zone2: statement1=foo, statement2=kangaroo
zone3: statement1=bar, statement2=koala
zone4: statement1=foo, statement2=koala
```

**manage-bind** support the following clauses:
- _options_
- _zone_
- _key_

### _Caution_ when defining a statement !
- some statements are defined with complex mappings while others requires just a simple value.
  Just in case, each statement have its own template self documented.
- **manage-bind** uses bind's tools **named-checkconf** and **named-checkzone** for configuration and zone validation.
  However, thoses tools are limited to **syntax** and **light coherence** verification. This role do not provide advanced validation methods.
- Escape special char like @ with quotes
- Some statements requires "yes|no" string values: Escape **yes** and **no** with quotes as Ansible evaluates them as boolean.

### The Options clause
**Note:** The role comes with some default options.
#### Defining options' statements
When calling **manage-bind**, you can pass options statements:
 - in an external YAML file declared with `options_file`.
   - it must contain a mapping of statements called `options`.
 - in a mapping called `options` inside your playbook

**Note:** _First method excludes the second:_ the role will load only the statements in the file if you declare it in your playbook.
> playbook.yml:
```
- hosts: dnsserver
  become: yes
  roles:
    - role: aalaesar.manage-bind
      options_file: ./files/options.yml # the role will only load those options
      options: # the next lines are useless is this case
        statement1: ...
        statement2: ...
```
> ./files/options.yml:
```
---
options:
  statement1: ...
  statement2: ...
```
The list of all the statements available for the options is in **./tests/bind_options.yml**

#### Changing the role's default options :
They are defined in **./defaults/default_options.yml**

You may use this file to share a common policy over your infrastructure and override specific options easily

### Zones clauses
Zone clauses are defined with **statement** _and_ **zone records**
#### zone declaration
Each zone is declared as an element of the list named `zones`.

**'zones'** have to be defined in the playbook and is _mandatory_.
> playbook.yml:
```
- hosts: dnsserver
  become: yes
  roles:
    - role: aalaesar.manage-bind
      zones:
        - ... # zone 1
        - ... # zone 2
```

#### Defining zone's statements
A zone is a mapping where its statements are keys:
- `[statement]:value`
- `name` and `type` are mandatory statements
- Some zone type have their own mandatory statements

> playbook.yml:
```
zones:
  - name: example.com # Mandatory. The domain's name
    type: master # Mandatory. The type of the zone : master|slave|forward|stub
    recursion: "no" # statement overriding global option "recursion" for this zone.
    ... # etc
```


The list of all zone's statements available is in **./tests/zone_statements.md**

#### Defining zone's records
the **zone's** records are defined in a mapping named **'records'**

This mapping **'records'** can be declared:
- in an YAML file specified in the **_yamlfile_** key.
- _as a zone's key_

**Note:** _First method excludes the second:_ the role will load only the records in the file if you declare it in your playbook.

> playbook.yml:
```
zones:
  - name: example.com
    records:
      SOA: ...
      NS: ...
      ... # etc
    ... # etc
  - name: test.tld
    yamlfile: "./files/test.tld.yml"
    records: # will be ignored in this zone
      SOA: ...
      NS: ...
    ... # etc
```

In the yaml file, **records** must be top level mapping:
> ./files/test.tld.yml:
```
---
records:
  SOA: ...
  NS: ...
  ... # etc
```

#### Adding records in the zone
Zone records have different types, they are declared by type inside `records`.

_each records type is different and follow its own YAML structure.
Most records templates are self documented._

Manage-bind support the following records
- **SOA**
- **NS**
- **A**
- **AAAA**
- **MX**
- **SRV**
- **PTR**
- **CNAME**
- **DNAME**
- **TXT**
- ttl can be declared along the zone's records

## Dependencies

None.

## Example Playbooks
### Exemple configuration :
- You own the zones example.tld, example.com and example.org
- You have 2 name servers : dnserver1 (11.22.33.44) & dnserver2 (55.66.77.88)
- dnserver1 is master of example.tld and slave of example.com.
- dnserver2 is master of example.com and slave of example.tld

### dnserver1's playbook :
```
---
- hosts: dnserver1
  roles:
    - role: aalaesar.manage-bind
      options:
        allow_recursion: '55.66.77.88'
        allow_transfer: '55.66.77.88'
      zones:
        - name: example.tld
          type: master
          notify: '55.66.77.88'
          records:
            - SOA:
                serial: 2016080401
                ns: dnserver1.example.tld.
                email: admin.example.tld.
            - NS:
              - dnserver1.example.tld.
              - dnserver2.example.tld.
            - A:
                dnserver1: 11.22.33.44
                dnserver2: 55.66.77.88
        - name: example.com
          type: slave
          masters: '55.66.77.88'
```
### dnserver2's playbook :
```
---
- hosts: dnserver2
  roles:
    - role: aalaesar.manage-bind
      options:
        allow_recursion: '11.22.33.44'
        allow_transfer: '11.22.33.44'
      zones:
        - name: example.com
          type: slave
          notify: '11.22.33.44'
        - name: example.tld
         type: slave
         masters: '11.22.33.44'
         ymlfile: example.com.yml
```
### YAML file for example.com.yml on dnserver2
```
---
records:
  ttl: 3d
  SOA:
    serial: 2016080401
    ns: dnserver2.example.com.
    email: admin.example.com.
  NS:
    - srvdns01.example.com.
  A:
    127.0.0.1:
      - '@'
      - dnserver2.example.com.
    host1: 12.34.56.78
    mailsrv: 98.76.54.32
    'ftp.domain.tld.': 95.38.94.196
  MX:
    '@':
      - target: backup.fqdn.
        priority: 20
  CNAME:
    host1: ftp
    '@':
      - www
      - webmail
  TXT:
    - text: '"v=spf1 mx -all"'
    - text: '( "v=DKIM1; k=rsa; t=s; n=core; p=someverylongstringbecausethisisakeyformailsecurity" )  ; ----- DKIM key mail for example.com'
      label: mail._domainkey
```

More examples are available in the tests folder
## License
BSD
