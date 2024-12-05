# Ansible role: rabbitmq

This role is for install standard rabbitmq instance.

# Requirements

system-init.

# Role variables

Have a look at: `defaults/main.yml`.


## Mandatory variables

None.

# Dependencies
None.

# Example Playbook

```
---
- hosts: all
  gather_facts: false
  roles:
    - role: system-init

    - role: rabbitmq
      when: rabbitmq_mode == 'standalone'
```

# Example Hosts

```
192.168.182.42 rabbitmq_mode=standalone
192.168.182.43 rabbitmq_mode=standalone
```

# Contribution


# License

Apache

# Author Information
Evan @ gmcc
liuchao-139@139.com
