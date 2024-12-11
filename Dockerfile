FROM alfg/ffmpeg:latest as ffmpeg
FROM ejnshtein/node-tdlib:latest
FROM node:19.5.0-alpine

WORKDIR /app/
# set tdlib
RUN cp /usr/local/lib/libtdjson.so ./libtdjson.so

# set ffmpeg deps
RUN apk add --update \
  ca-certificates \
  openssl \
  pcre \
  lame \
  libogg \
  libass \
  libvpx \
  libvorbis \
  libwebp \
  libtheora \
  opus \
  rtmpdump \
  x264-dev \
  x265-dev \
  curl

# copy ffmpeg
COPY --from=ffmpeg /opt/ffmpeg /opt/ffmpeg
COPY --from=ffmpeg /usr/lib/libfdk-aac.so.2 /usr/lib/libfdk-aac.so.2
COPY --from=ffmpeg /usr/lib/librav1e.so /usr/lib/librav1e.so
COPY --from=ffmpeg /usr/lib/libx265.so /usr/lib/
COPY --from=ffmpeg /usr/lib/libx265.so.* /usr/lib/

ENV PATH=/opt/ffmpeg/bin:$PATH

ADD ./package.json ./package-lock.json ./tsconfig.json ./

RUN npm ci

ADD ./src ./src
ADD ./types ./types
ADD ./tsconfig.json ./tsconfig.json

COPY ./accs.sh /accs.sh
RUN chmod +x /accs.sh

RUN npm run build-ts

CMD /accs.sh && npm start
#CMD [ "npm", "start" ]
