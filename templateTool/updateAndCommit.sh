#!/bin/sh
chmod +x export
cd ../
svn up
cd templateTool/
sh export
cd ../scripts/common/template
svn add `svn st| grep -E '^\?' |awk '{print $2}'`  --username server
svn commit -m "template commit" --username server
