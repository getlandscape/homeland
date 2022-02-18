# frozen_string_literal: true

class GroupUser < ApplicationRecord
  acts_as_paranoid

  enum role: %i[owner admin member]
  enum status: %i[pendding accepted declined removed withdrew]
  enum last_action_type: %i[apply approve upgrade downgrade owner_transfer decline remove withdraw]

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

  after_commit :send_update_notification
  def send_update_notification
    if previous_changes.slice("role", "status").present?
      Notifications::GroupUser.new(self).notify unless user_id == last_actor_id
    end
  end

  after_create :send_create_notification
  def send_create_notification
    Notifications::GroupUser.new(self).notify
  end
end
