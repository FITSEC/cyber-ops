#!/bin/bash

xargs -a /opt/packages.txt apt-get install -y --ignore-missing --fix-missing 