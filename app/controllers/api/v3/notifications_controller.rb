module Api
  module V3
    class NotificationsController < ApplicationController
      before_action :doorkeeper_authorize!

      ##
      # 获取用户的通知列表
      #
      # GET /api/v3/notifications
      #
      # params:
      #   offset - default: 0
      #   limit - default: 20, range: 1..150
      #
      def index
        optional! :offset, default: 0
        optional! :limit, default: 20, values: 1..150

        @notifications = Notification.where(user_id: current_user.id).order('id desc')
                                     .offset(params[:offset])
                                     .limit(params[:limit])

        render json: @notifications
      end

      ##
      # 将当前用户的一些通知设成已读状态
      #
      # POST /api/v3/notifications/read
      #
      # params:
      #   ids - <Array> of Notification id, [required]
      #
      def read
        requires! :ids

        if params[:ids].length > 0
          @notifications = current_user.notifications.where(id: params[:ids])
          Notification.read!(@notifications.collect(&:id))
        end

        render json: { ok: 1 }, status: 201
      end

      ##
      # 删除当前用户的所有通知
      #
      # DELETE /api/v3/notifications/all
      #
      def all
        current_user.notifications.delete_all
        render json: { ok: 1 }
      end

      ##
      # 获得未读通知数量
      #
      # GET /api/v3/notifications/unread_count
      #
      def unread_count
        render json: { count: Notification.unread_count(current_user) }
      end

      ##
      # 删除当前用户的某个通知
      #
      # DELETE /api/v3/notifications/:id
      #
      def destroy
        @notification = current_user.notifications.find(params[:id])
        @notification.destroy
        render json: { ok: 1 }
      end
    end
  end
end
