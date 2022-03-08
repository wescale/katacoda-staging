FROM alpine:latest

RUN apk add wget uuidgen jq
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc
RUN chmod +x mc
ADD run.sh .
RUN chmod +x run.sh

ENTRYPOINT ["sh", "run.sh"]
