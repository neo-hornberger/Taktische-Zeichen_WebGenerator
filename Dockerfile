# https://raw.githubusercontent.com/edwardinubuntu/flutter-web-dockerfile/master/Dockerfile

FROM debian:stable-slim AS build-env

ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.22.1

RUN apt-get update
RUN apt-get install -y curl git unzip

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

ENV PATH="${FLUTTER_SDK}/bin:${FLUTTER_SDK}/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v

WORKDIR /app
COPY . .

RUN flutter clean
RUN flutter pub get
RUN flutter build web


FROM nginx:alpine-slim

COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]
