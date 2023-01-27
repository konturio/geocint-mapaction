#!/bin/bash

set -e

sudo apt-get install -y curl awscli

ln -s ${GEOCINT_WORK_DIRECTORY}/geocint/completeness_report ${GEOCINT_WORK_DIRECTORY}/public_html/completeness_report
ln -s ${GEOCINT_WORK_DIRECTORY}/geocint/completeness ${GEOCINT_WORK_DIRECTORY}/public_html/completeness