# syntax=docker/dockerfile:1
FROM drecom/ubuntu-ruby:2.2.10
RUN apt-get update -qq && apt-get install -y \
    libsqlite3-dev \
    build-essential \
    libpq-dev \
    nodejs \
    xvfb \
    qt5-default \
    libqt5webkit5-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    imagemagick \
    graphviz

RUN gem install bundler -v 1.17.3
RUN gem install concurrent-ruby -v 1.1.10
RUN gem install rails -v 4.0.0

WORKDIR /usr/src/app

COPY . .
RUN bundle install

EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]