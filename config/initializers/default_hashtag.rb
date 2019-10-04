# frozen_string_literal: true

Rails.application.configure do
  if Tag.table_exists?
    config.x.default_hashtag = ENV['DEFAULT_HASHTAG']
    config.x.default_hashtag_id = Tag.find_by(name: ENV['DEFAULT_HASHTAG'].downcase)
  end
  config.x.keyword_hashtag_visibility = !(ENV['KEYWORD_HASHTAG_VISIBILITY'].==('none'))
end
