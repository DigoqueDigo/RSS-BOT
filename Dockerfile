FROM ruby:3.3-slim

COPY . /var/www/rss-bot

WORKDIR /var/www/rss-bot

RUN apt update
RUN apt-get install -y build-essential libsodium-dev
RUN bundle install

CMD ["ruby", "src/bot.rb", "feeds/feeds.yml"]