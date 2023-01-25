#!/bin/bash

set -e

sudo apt-get install -y curl awscli

ln -s ${GEOCINT_WORK_DIRECTORY}/completeness_report/ ${GEOCINT_WORK_DIRECTORY}/public_html/completeness_report/
ln -s ${GEOCINT_WORK_DIRECTORY}/report/ ${GEOCINT_WORK_DIRECTORY}/public_html/report/