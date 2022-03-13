# frozen_string_literal: true

class UserTopic < ApplicationRecord
	belongs_to :user
	belongs_to :topic

	enum status: %i[draft pendding joined]

	scope :none_pendding, -> { where.not(status: 'pendding').order(updated_at: :desc) }
  scope :marked, -> { where(is_marked: true) }

	def self.total_pages
    return @total_pages if defined? @total_pages

    topic_id = self.pluck(:topic_id).first

    total_count = Rails.cache.fetch("user_topics/total_count/#{topic_id}", expires_in: 1.week) do
      self.count
    end
    if total_count >= 1500
      @total_pages = 60
    end
    @total_pages
  end
end