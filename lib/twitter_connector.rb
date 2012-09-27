require 'faraday'
require 'time-ago-in-words'

class TwitterConnector < BaseConnector

  cached_path 'cache/twitter.yml'

  def initialize
    query = %w(fulcrumapp spatialnetworks).join('%20OR%20')
    @connection = Faraday.new(url: "http://search.twitter.com/search.json?q=#{query}")
  end

  def fetch
    [].tap do |array|
      JSON.parse(@connection.get.body)['results'].each do |tweet|
        array << {
          image: tweet['profile_image_url'],
          text: tweet['text'],
          from_user: tweet['from_user'],
          created_at: Time.parse(tweet['created_at']).ago_in_words
        }
      end
    end
  end
end
