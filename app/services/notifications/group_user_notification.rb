# frozen_string_literal: true
module Noitification
  class GroupUserNotification
    def initialize(group_user, action)
      @group_user = group_user
      @action = action
    end

    def raw_data
      meta_data.merge { target: @group_user, second_target: group }
    end

    def group
      @group_user.group
    end

    def admin_ids
      group.group_users.admins.pluck(:user_id)
    end
  end
end

