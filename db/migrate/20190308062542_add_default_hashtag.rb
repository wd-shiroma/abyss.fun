class AddDefaultHashtag < ActiveRecord::Migration[5.2]
  def change
    tag = Tag.where(name: ENV['DEFAULT_HASHTAG']).first_or_initialize(name: ENV['DEFAULT_HASHTAG'])
    tag.save
  end
end
