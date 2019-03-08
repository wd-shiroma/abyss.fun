# frozen_string_literal: true
require 'natto'

class ProcessHashtagsService < BaseService
  def call(status, tags = [])
    tags    = Extractor.extract_hashtags(status.text) if status.local?
    records = []

    if status.local && !status.reply? then
      nm = Natto::MeCab.new
      enum = nm.enum_parse(status.text)

      tagged_status = status.text
      kw_tags = []

      enum.each do |e|
        f = e.feature.split(",")
        kw_tags.concat(f[9].split(":")) if f.length > 9
      end

      (kw_tags.compact.uniq(&:to_s) - status.tags.map(&:name)).each do |name|
        tags << name
        tagged_status = "#{tagged_status} \##{name}"
      end

      status.update(text: tagged_status) unless Rails.configuration.x.keyword_hashtag_visibility?
    end

    tags.map { |str| str.mb_chars.downcase }.uniq(&:to_s).each do |name|
      tag = Tag.where(name: name).first_or_create(name: name)

      status.tags << tag
      records << tag

      TrendingTags.record_use!(tag, status.account, status.created_at) if status.public_visibility?
    end

    return unless status.public_visibility? || status.unlisted_visibility?

    status.account.featured_tags.where(tag_id: records.map(&:id)).each do |featured_tag|
      featured_tag.increment(status.created_at)
    end
  end
end
