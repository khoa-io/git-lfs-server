#!/bin/bash

mkdir -p output

curl http://$1/oid/5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef \
-X GET \
-H "Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=" \
--output output/binary_file.bin

shasum -a 256 output/binary_file.bin -c test/data/CHECKSUM

rm -rf output
