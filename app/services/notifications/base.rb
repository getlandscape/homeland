# frozen_string_literal: true

module Notifications
  class Base
    def notify
      Notification.create(create_params)
    end

    def create_params
      if @receiver_id.is_a?(Array)
        @receiver_id.map { |id| { 
                                  notify_type: @notify_type,
                                  target: @target,
                                  second_target: @second_target,
                                  actor_id: @actor_id,
                                  user_id: id 
                                }
                         }
      else
        {
          notify_type: @notify_type,
          target: @target,
          second_target: @second_target,
          actor_id: @actor_id,
          user_id: @receiver_id
        }
      end
    end
  end
end
