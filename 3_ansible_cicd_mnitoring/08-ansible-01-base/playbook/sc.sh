#!/usr/bin/env bash
docker run -d --name centos7 pycontribs/centos:7 sleep 700000
docker run -d --name ubuntu pycontribs/ubuntu:latest sleep 700000
docker run -d --name fedora pycontribs/fedora:latest sleep 700000

ansible-playbook -i ./inventory/prod.yml site.yml --ask-vault-pass

docker stop centos7 ubuntu fedora
