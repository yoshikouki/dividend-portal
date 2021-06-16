FROM rubylang/ruby:3.0-focal

ENV LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    BUNDLE_JOBS=4

RUN apt-get update -qq \
 && apt-get install -y \
    nodejs \
    npm \
    postgresql-client \
    libpq-dev \
 && npm i -g yarn \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /src/*.deb

WORKDIR /app

RUN bundle config set path /app/vendor/bundle
