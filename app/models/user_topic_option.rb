# frozen_string_literal: true

class UserTopicOption < ApplicationRecord
	belongs_to :user
	belongs_to :topic
	belongs_to :topic_option
end