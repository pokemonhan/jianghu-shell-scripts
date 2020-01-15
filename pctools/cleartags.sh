#!/bin/sh
cd /e/projects/jianghu_entertain;
git tag -l | xargs git tag -d && git fetch -t
###################################################
echo Press Enter...
read
