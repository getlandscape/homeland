# frozen_string_literal: true

require "digest/md5"
module GroupUsersHelper
  def group_user_group_tag(group_user, opts = {})
    group = group_user.group
    return t("groups.group_was_deleted") if group.blank?

    link_to(group.name, main_app.group_path(group), title: group.name, class: "topic-title")
  end

  def group_user_user_tag(group_user, opts = {})
    user = group_user.user
    return t("users.user_was_deleted") if user.blank?

    link_to(user.name, main_app.user_path(user), title: user.name, class: "topic-title")
  end
end
