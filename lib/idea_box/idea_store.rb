require 'yaml/store'

class IdeaStore

  def self.database
    return @database if @database

    @database = YAML::Store.new('db/ideabox')
    @database.transaction do
      @database['ideas'] ||= []
    end
    @database
  end

  def self.all
    ideas = []
    raw_ideas.each_with_index do |data, i|
      ideas << Idea.new(data.merge("id" => i))
    end
    ideas
  end

  def self.all_tags
    # No need to define the all_tags the variable here
    all.map { |idea| idea.tags_array }.flatten.uniq
  end

  def self.view_by_tag(tag)
    if tag == "All"
      all
    else
      all.find_all { |idea| idea.tags_array.include?(tag) }
    end
  end

  def self.grouped_by_tags
    # Just a little simplification
    gbt = {}
    all_tags.each do |key|
      gbt[key] = all.find_all {|idea| idea.tags_array.include?(key)}
    end
    gbt
  end

  def self.raw_ideas
    database.transaction do |db|
      db['ideas'] || []
    end
  end

  def self.delete(position)
    database.transaction do
      database['ideas'].delete_at(position)
    end
  end

  def self.find(id)
    raw_idea = find_raw_idea(id)
    Idea.new(raw_idea.merge("id" => id))
  end

  def self.find_raw_idea(id)
    database.transaction do
      database['ideas'].at(id)
    end
  end

  def self.update(id, params)
    idea = find(id.to_i)
    updated_params = idea.to_h.merge(params)
    database.transaction do
      database['ideas'][id] = updated_params
    end
  end

  def self.create(data)
    database.transaction do
      database['ideas'] << data
    end
  end

end
