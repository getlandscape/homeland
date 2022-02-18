# frozen_string_literal: true

module Notifications
  class GroupUser < Notifications::Base
    def initialize(group_user)
      @group_user = group_user
      @notify_type = 'group_user'
      @target = group_user
      @second_target = group
      @actor_id = actor_id
      @receiver_id = receiver_id
    end

    def actor_id
      @group_user.last_actor_id
    end

    def receiver_id
      return admin_ids if @group_user.pendding? && @group_user.last_action_type == 'apply'

      @group_user.user_id
    end

    def group
      @group_user.group
    end

    def admin_ids
      group.group_users.admins.pluck(:user_id)
    end
  end
end
