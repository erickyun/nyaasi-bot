# Stage 1: Get ffmpeg binaries
FROM alfg/ffmpeg:latest as ffmpeg

# Stage 2: Get libtdjson.so from node-tdlib
FROM ejnshtein/node-tdlib:latest as tdlib

# Stage 3: Final image
FROM node:19.5.0-alpine

WORKDIR /app/

# Set tdlib: copy libtdjson.so from tdlib stage
#COPY --from=tdlib /usr/local/lib/libtdjson.so /usr/local/lib/libtdjson.so
#RUN cp /usr/local/lib/libtdjson.so ./libtdjson.so
COPY --from=tdlib /usr/local/lib/libtdjson.so ./libtdjson.so

# Install ffmpeg dependencies
RUN apk add --update --no-cache \
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

# Copy ffmpeg binaries and libraries
COPY --from=ffmpeg /opt/ffmpeg /opt/ffmpeg
COPY --from=ffmpeg /usr/lib/libfdk-aac.so.2 /usr/lib/libfdk-aac.so.2
COPY --from=ffmpeg /usr/lib/librav1e.so /usr/lib/librav1e.so
COPY --from=ffmpeg /usr/lib/libx265.so /usr/lib/
COPY --from=ffmpeg /usr/lib/libx265.so.* /usr/lib/

# Add ffmpeg to PATH
ENV PATH=/opt/ffmpeg/bin:$PATH

# Copy application files
ADD ./package.json ./package-lock.json ./tsconfig.json ./

# Install dependencies
#RUN npm ci

# Add source code and configuration
ADD ./src ./src
ADD ./types ./types

# Copy entrypoint script and make it executable
COPY ./accs.sh /accs.sh
RUN chmod +x /accs.sh

# Build the TypeScript project
RUN npm run build-ts
RUN npm audit fix

# Set the entrypoint command
CMD /accs.sh && npm start
