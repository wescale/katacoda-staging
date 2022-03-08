FROM alpine:latest

RUN apk add wget uuidgen
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc
RUN chmod +x mc
ADD run.sh .
RUN chmod +x run.sh

ENTRYPOINT ["./run.sh"]

# docker run -e MINIO_URL=http://localhost:9000 -e MINIO_ACCESS_KEY=rootuser  -e MINIO_SECRET_KEY=rootpass123  -e FILE_URL=https://static.wikia.nocookie.net/pixar/images/0/06/Io_Sadness_standard2.jpg/revision/latest/scale-to-width-down/200 test
