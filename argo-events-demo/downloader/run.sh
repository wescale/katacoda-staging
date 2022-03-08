#!/bin/sh
echo $MINIO_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY $1
./mc alias set minio $MINIO_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY --api S3v4
uuid=$(uuidgen)
wget $1 -O $uuid
./mc cp $uuid minio/$uuid
