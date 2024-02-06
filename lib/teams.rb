# frozen_string_literal: true

class Teams
  attr_reader :yaml

  def initialize(filename)
    @yaml = YAML.safe_load_file(filename)
  end

  def exists?(slug)
    @yaml['teams'].key?(slug)
  end

  def prefix
    @yaml['prefix'] || ENV['PREFIX']
  end

  def from_topic(topic)
    @yaml['teams'].select { |_k, v| v['topic'] == topic.sub(prefix, '') }.keys[0]
  end

  def from_slug(slug)
    @yaml['teams'][slug] || nil
  end

  # Look up the permission level for a team by either their
  # slug or the topic assigned to them
  def permission(slug_or_topic)
    return @yaml['teams'][slug_or_topic]['permission'] if @yaml['teams'].key?(slug_or_topic)

    @yaml['teams'].select { |_k, v| v['topic'] == slug_or_topic.sub(prefix, '') }.values.first['permission']
  rescue NoMethodError
    nil
  end

  def topic(slug)
    "#{prefix}#{@yaml['teams'][slug]['topic']}"
  end

  def filter_repo_topics(topics)
    topics.select { |topic| topic.start_with?(prefix) }
  end
end
