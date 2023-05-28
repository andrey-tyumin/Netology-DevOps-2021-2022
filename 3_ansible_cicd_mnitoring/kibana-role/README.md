Filebeat Role
=========

Роль для установки Kibana

Requirements
------------

OS: Debian based, RHEL based

Role Variables
--------------
| Variable name | Default | Description |
|-----------------------|----------|-------------------------|
| kibana_version        | "7.15.0" | Версия Kibana для установки(на данный момент 7.15.0) |
| kibana_install_type   | remote   | Откуда будем качать файл дистрибутива(с control host(указываем remote), или managed(любое значение или пусто)

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

Andrey Tyumin
