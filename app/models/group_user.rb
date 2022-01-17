# frozen_string_literal: true

class GroupUser < ApplicationRecord
  enum role: %i[owner admin member]
  enum status: %i[pendding accepted rejected]

  belongs_to :group
  belongs_to :user

  scope :admins, -> { where.not(role: 'member') }
  scope :admin_only, -> { where.(role: 'admin') }
end
