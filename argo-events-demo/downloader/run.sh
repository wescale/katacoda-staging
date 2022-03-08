#!/bin/sh
echo $MINIO_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY $1
./mc alias set minio $MINIO_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
uuid=$(uuidgen)
url=$(echo $1 | jq '.url')
wget $url -O $uuid
./mc cp $uuid minio/$uuid
