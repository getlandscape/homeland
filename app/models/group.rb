# frozen_string_literal: true

class Group < ApplicationRecord
  mount_uploader :avatar, GroupPhotoUploader

  LETTER_AVATAR_REGEXP = /([a-z0-9])/i

  enum group_type: %i[public_group private_group]
  enum status: %i[pendding approved rejected]

  validates :name, :description, presence: true
  validate :check_topic_ban_words, on: :create

  has_many :group_users
  has_many :users, through: :group_users

  has_many :topics

  scope :approved_groups, -> { where(status: 'approved') }

  def self.total_pages
    return @total_pages if defined? @total_pages

    total_count = Rails.cache.fetch("groups/total_count", expires_in: 1.week) do
      approved_groups.count
    end
    if total_count >= 1500
      @total_pages = 60
    end
    @total_pages
  end

  def description_first_line
    description.lines.first.chomp
  end

  def owner
    group_users.find_by(role: :owner).try(:user)
  end

  def letter_avatar_char
    matchs = name.scan(/[a-zA-Z]{1}/)
    return "G" if matchs.blank?
    (matchs[0] || "-").downcase
  end

  def letter_avatar_url(size)
    avatar_path = File.join("letter_avatars", letter_avatar_char + ".png")

    "#{Setting.base_url}/system/#{avatar_path}"
  end

  def group_member?(user)
    return false unless user.present?
    group_users.accepted.pluck(:user_id).include? user.id
  end

  def group_admin?(user)
    return false unless user.present?
    group_users.accepted.admin_only.pluck(:user_id).include? user.id
  end
end
