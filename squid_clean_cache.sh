#!/bin/bash

pkill squid

find /var/cache/squid/* |grep -v ssl_db |xargs rm -rf

squid -z
