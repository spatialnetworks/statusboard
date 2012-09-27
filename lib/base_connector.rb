class BaseConnector
  class << self

    def cached_path(path)
      @cached_path = path
    end

    def cache
      @cached_path
    end

    def cached_duration(duration)
      @cached_duration = duration
    end

    def duration
      @cached_duration || (60 * 4)
    end

    def fetch!
    # Cache the file on disk for 3 minutes.
      if File.exists?(cache) && File.ctime(cache) + duration > Time.now
        YAML.load(File.read(cache))
      else
        self.new.fetch.tap do |result|
          File.open(cache, 'w+') { |f| f.write YAML.dump(result) }
        end
      end
    rescue
      []
    end
  end
end
