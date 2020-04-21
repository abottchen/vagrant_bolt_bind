#!/bin/bash
mkdir -p /srv/docker/bind
tar -xvf /tmp/bind_files.tar.gz -C /srv/docker
rm /tmp/bind_files.tar.gz
