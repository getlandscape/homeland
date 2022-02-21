# frozen_string_literal: true

require "digest/md5"
module NotificationsHelper
  def second_target_tag(notification, opts = {})
    obj = notification.second_target
    return t("notifications.group_was_deleted") if obj.blank?

    link_to(obj.name, main_app.group_path(obj), title: obj.name, class: "topic-title")
  end

  def actor_tag(notification, opts = {})
    obj = notification.actor
    return t("notifications.user_was_deleted") if obj.blank?

    link_to(obj.name, main_app.user_path(obj), title: obj.name, class: "topic-title")
  end

  def receiver_tag(notification, opts = {})
    obj = User.find notification.target.last_actor_id
    return t("notifications.user_was_deleted") if obj.blank?

    link_to(obj.name, main_app.user_path(obj), title: obj.name, class: "topic-title")
  end
end
