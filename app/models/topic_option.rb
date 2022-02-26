# frozen_string_literal: true

class TopicOption < ApplicationRecord
	belongs_to :topic

	has_many :user_topic_options, dependent: :destroy
end