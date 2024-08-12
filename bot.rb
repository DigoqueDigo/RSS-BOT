require 'yaml'
require 'feedjira'
require 'open-uri'
require 'discordrb'
require 'discordrb/webhooks'
require 'dotenv/load'

$last_entries = {}
$last_entries_file = ".last_entries.yml"

feed_links_file = "rss.yml"
feed_links = YAML.load_file(feed_links_file)

bot = Discordrb::Bot.new(token: ENV['DISCORD_BOT_TOKEN'])


if File.exist?($last_entries_file)
    $last_entries = YAML.load_file($last_entries_file)
end


def check_rss_feed(bot,link,channel_id)

    content = URI.open(link).read
    feed = Feedjira.parse(content)
    feed.entries = feed.entries.sort_by(&:published)

    feed.entries.each do |entry|

        if !$last_entries.key?(link) || ($last_entries[link] <=> entry.published) == -1

            embed = Discordrb::Webhooks::Embed.new(
                title: entry.title,
                description: entry.summary,
                url: entry.id,
                color: 0x4C9900,
                timestamp: entry.published)

            embed.author = Discordrb::Webhooks::EmbedAuthor.new(
                name: entry.author)

            bot.channel(channel_id).send_embed('',embed)
        end
    end

    $last_entries[link] = "#{feed.entries.last().published}"

    File.open($last_entries_file, 'w') do |file|
        file.write(YAML.dump($last_entries))
    end
end


#scheduler = Rufus::Scheduler.new
#scheduler.every '1h' do
#  check_rss_feeds(bot, RSS_URLS, CHANNEL_ID)
#end

bot.message(content: '!rss') do |event|
    feed_links['feeds'].each do |link|
        check_rss_feed(bot,link,ENV['CHANNEL_ID'])
    end
end

bot.run