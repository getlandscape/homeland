# frozen_string_literal: true

class UserTopic < ApplicationRecord
	belongs_to :user
	belongs_to :topic

	enum status: %[mark join]
end