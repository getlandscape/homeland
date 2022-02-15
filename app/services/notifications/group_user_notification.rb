# frozen_string_literal: true
module Noitification
  class GroupUserNotification
    def initialize(group_user, action)
      @group_user = group_user
      @action = action
    end

    def meta_data
      case @action
      when 'update'
      when 'create'
      end
    end
  end
end


Notification.create(
  notify_type: @klass,
  target: @target,
  second_target: @second_target,
  actor_id: @actor.id,
  user_id: @receiver.id
)
