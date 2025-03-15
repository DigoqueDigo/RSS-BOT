# RSS Discord Bot

This bot was created specifically for my website, so the parsing process doesn't fit the structure of any feed, which is why I don't recommend using it for your website. This problem could be solved with a little effort, but I don't feel like wasting time on it.

### Run Localy
```bash
bundle install
ruby src/bot.rb feeds/feeds.yml
```

### Run Docker
```bash
docker compose up -d
```

### Feeds
```yml
example_1:
  link: https://example_1/feed.xml
  channel_id: '1350509300715487373'
example_2:
  link: https://example_2/feed.xml
  channel_id: '1350509300715487374'
```