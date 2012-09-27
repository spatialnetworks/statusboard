require 'faraday'
require 'syndication/rss'
require 'json'

class BlogConnector < BaseConnector

  SPATIAL_NETWORKS_BLOG = 'http://spatialnetworks.com/?feed=rss2'
  MAX_BLOG_POSTS = 3
  cached_path 'cache/blog.yml'

  def initialize
    @parser = Syndication::RSS::Parser.new
    @connection = Faraday.new(url: 'http://feeds.feedburner.com/spatialnetworks')
    @posts = []
  end

  def fetch
    formatter
  end

  def formatter
    [].tap do |array|
      parsed[0..(MAX_BLOG_POSTS - 1)].each do |post|
        photos = fetch_image_urls(post.comments.gsub(/#comments/, ''))
        array << {
          title: post.title,
          description: truncate(post.description, length: 200, omission: '... (continued)'),
          count: photos.length,
          photos: photos
        }
      end
    end
  end

  def parsed
    @parsed ||= @parser.parse(@connection.get.body).items
  end

  def truncate(string, options)
    if string.length > options[:length]
      string[0..(options[:length] - options[:omission].length - 1)] + options[:omission]
    else
      string
    end
  end

  def fetch_image_urls(url)
    conn = Faraday.new(url: "http://otter.topsy.com/trackbacks.js?url=#{url}&perpage=100")
    JSON.parse(conn.get.body)['response']['list'].map do |post|
      post['author']['photo_url']
    end
  end
end
