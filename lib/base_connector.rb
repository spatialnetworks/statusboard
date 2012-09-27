class BaseConnector
  def self.fetch!
    # Cache the file on disk for 3 minutes.
    if File.exists?(self.cached_path) && File.ctime(self.cached_path) + (60 * 3) > Time.now
      YAML.load(File.read(self.cached_path))
    else
      self.new.fetch.tap do |result|
        File.open(self.cached_path, 'w+') { |f| f.write YAML.dump(result) }
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
      end
    end
  rescue
    []
  end
end
