require 'yaml'
require 'logger'
require 'feedjira'
require 'open-uri'
require 'nokogiri'
require 'discordrb'
require 'discordrb/webhooks'
require 'dotenv/load'
require 'rufus-scheduler'

$logger = Logger.new(STDOUT)

feeds_file = ARGV[0]
feeds = YAML.load_file(feeds_file)

scheduler = Rufus::Scheduler.new
bot = Discordrb::Bot.new(token: ENV['DISCORD_BOT_TOKEN'])


def save_feeds(feeds,filename)
    File.open(filename,'w') do |file|
        file.write(YAML.dump(feeds))
    end
end


def get_thumbnail(url)
    html = Nokogiri::HTML(URI.open(url))
    html.at_css('meta[property="og:image"]')['content']
end


def check_rss_feed(site, params, bot)

    content = URI.open(params['link']).read
    feed = Feedjira.parse(content)
    feed.entries = feed.entries.sort_by(&:published)

    feed.entries.each do |entry|

        if !params.key?('update') || (params['update'] <=> String(entry.published)) == -1

            embed = Discordrb::Webhooks::Embed.new(
                title: entry.title,
                description: entry.summary,
                url: entry.url,
                color: 0x4C9900,
                timestamp: entry.published)

            embed.author = Discordrb::Webhooks::EmbedAuthor.new(
                name: entry.author)

            embed.fields = [Discordrb::Webhooks::EmbedField.new(
                name: 'Categorias',
                value: entry.categories.join(', '),
                inline: true)]

            embed.image = Discordrb::Webhooks::EmbedImage.new(
                url: get_thumbnail(entry.url))

            bot.channel(params['channel_id']).send_embed('',embed)
            $logger.info(entry.url)
        end
    end

    params['update'] = String(feed.entries.last().published)
end


scheduler.every '10s' do
    $logger.info("Check feeds")
    feeds.each do |site, params|
        check_rss_feed(site, params, bot)
    end
    save_feeds(feeds,feeds_file)
end


bot.message(content: '!rss') do |event|
    feeds.each do |site, params|
        check_rss_feed(site, params, bot)
    end
    save_feeds(feeds,feeds_file)
end

bot.run