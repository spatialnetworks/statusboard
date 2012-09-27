class BaseConnector
  def self.fetch!
    # Cache the file on disk for 5 minutes.
    if File.exists?(self.cached_path) && File.ctime(self.cached_path) + (60 * 5) > Time.now
      YAML.load(File.read(self.cached_path))
    else
      self.new.fetch.tap do |result|
        File.open(self.cached_path, 'w+') { |f| f.write YAML.dump(result) }
      end
    end
  rescue
    []
  end
end
