# frozen_string_literal: true

class NotificationGenerator
  def initialize(actor, reciever, notify_type, target, second_target = nil)
    @actor = actor
    @receiver = receiver
    @notify_type = notify_type
    @target = target
    @second_target = second_target
  end

  def create_notification
    Notification.create(
      notify_type: @klass,
      target: @target,
      second_target: @second_target,
      actor_id: @actor.id,
      user_id: @receiver.id
    )
  end
end
