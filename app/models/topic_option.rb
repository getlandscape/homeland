# frozen_string_literal: true

class TopicOption < ApplicationRecord
	belongs_to :topic

	has_many :user_topic_options, dependent: :destroy

	def self.vote_params(topic_id, option_ids)
		self.where(topic_id: topic_id, id: option_ids).map { |to| { topic_option_id: to.id, topic_id: to.topic_id } }
	end
end