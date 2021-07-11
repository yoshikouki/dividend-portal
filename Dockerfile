FROM rubylang/ruby:3.0-focal

ENV LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    BUNDLE_JOBS=4 \
    BUNDLE_PATH=/app/vendor/bundle

RUN apt-get update -qq \
 && apt-get install -y \
    nodejs \
    npm \
    postgresql-client \
    libpq-dev \
    libidn11-dev
RUN npm i -g yarn
RUN rm -rf /var/lib/apt/lists/* \
 && rm -rf /src/*.deb

WORKDIR /app
