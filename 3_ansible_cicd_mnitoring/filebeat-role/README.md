Filebeat Role
=========

Роль для установки Filebeat

Requirements
------------

OS: Debian based, RHEL based

Role Variables
--------------
| Variable name | Default | Description |
|-----------------------|----------|-------------------------|
| filebeat_version      | "7.15.0" | Версия Filebeat для установки(на данный момент 7.15.0) |
|filebeat_install_type  | remote   | Откуда будем качать файл дистрибутива(с control host(указываем remote), или managed(любое значение или пусто)

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
