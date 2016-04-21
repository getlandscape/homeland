module Api
  module V3
    class RepliesController < ApplicationController
      before_action :doorkeeper_authorize!, only: [:update, :destroy]
      before_action :set_reply, only: [:show, :update, :destroy]

      # 获取回帖的详细内容（一般用于编辑回帖的时候）
      def show
        render json: @reply, serializer: ReplyDetailSerializer
      end

      # 更新回帖
      def update
        raise AccessDenied unless can?(:update, @reply)

        requires! :body

        @reply.body = params[:body]
        @reply.save!
        render json: @reply, serializer: ReplyDetailSerializer, status: 201
      end

      # 删除回帖
      def destroy
        raise AccessDenied unless can?(:destroy, @reply)

        @reply.destroy
        render json: { ok: 1 }
      end

      private
      def set_reply
        @reply = Reply.find(params[:id])
      end
    end
  end
end
