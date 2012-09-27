require 'github_api'

class GithubConnector < BaseConnector

  MAX_COMMITS = 30
  cached_path 'cache/github.yml'

  def self.config
    @@config ||= YAML.load(File.read('config/github.yml'))
  end

  def self.auth
    "#{self.config['username']}:#{self.config['password']}"
  end

  def initialize
    @config     = self.class.config
    @connection = Github.new(basic_auth: GithubConnector.auth)
    @commits    = 0
  end

  def fetch
    [].tap do |array|
      return array if @commits >= 30
      @connection.events.user_org(self.class.config['username'], 'spatialnetworks').each do |event|
        if event.type == 'PushEvent'
          repo = event.repo.name.gsub("spatialnetworks/", "")
          hash = {
            avatar: event.actor.avatar_url,
            subtitle: event.payload.ref.gsub("refs/heads/", ""),
            created_at: Time.parse(event.created_at).ago_in_words,
            commits: generate_commit_array(event, repo),
            repo: repo
          }
          array.push(hash)
        end
      end
    end
  end

  def generate_commit_array(event, repo)
    [].tap do |array|
      event.payload.commits.each do |event|
        commit = @connection.repos.commits.get('spatialnetworks', repo, event.sha)
        array << {
          sha: event.sha,
          message: event.message,
          additions: commit.stats.additions,
          deletions: commit.stats.deletions
        }
        @commits += 1
      end
    end
  end
end
