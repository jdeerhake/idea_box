class Idea

  include Comparable

  attr_reader :title, :description, :rank, :id, :tags

  def initialize(attributes = {})
    @title = attributes["title"]
    @description = attributes["description"]
    @rank = attributes["rank"] || 0
    @id = attributes["id"]
    @tags = attributes["tags"]
  end

  def tags_array
    # I think this method could use a quick refactor to simplify it a little.
    # I don't see why @tags would ever be an empty array, am I missing something?
    return [] if @tags.nil?
    @tags.split(",").map {|tag| tag.strip}
  end

  def <=>(other)
    other.rank <=> rank
  end

  def save
    IdeaStore.create()
  end

  def to_h
    instance_variables.each_with_object({}) do |var, hash|
      hash[var.to_s.delete("@")] = instance_variable_get(var)
    end
  end

  def like!
    @rank += 1
  end

end
