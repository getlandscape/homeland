# frozen_string_literal: true

class GroupUser < ApplicationRecord
  enum role: %i[owner admin member]
  enum status: %i[pendding accepted rejected]

  belongs_to :group
  belongs_to :user

  scope :admins, -> { where.not(role: 'member') }
  scope :admin_only, -> { where(role: 'admin') }

  def self.total_pages
    return @total_pages if defined? @total_pages

    group_id = self.pluck(:group_id).first

    total_count = Rails.cache.fetch("group_users/total_count/#{group_id}", expires_in: 1.week) do
      self.count
    end
    if total_count >= 1500
      @total_pages = 60
    end
    @total_pages
  end
end
