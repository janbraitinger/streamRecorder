FROM alpine
COPY . .
RUN chmod +x streamRecorder.sh

RUN apk add tzdata
ENV TZ=Europe/Berlin
RUN apk update && apk upgrade

RUN apk add --no-cache --upgrade bash
RUN apk add  --no-cache ffmpeg
RUN apk add jq


CMD ["./streamRecorder.sh"]