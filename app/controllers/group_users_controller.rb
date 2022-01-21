# frozen_string_literal: true

class GroupUsersController < ApplicationController
  before_action :authenticate_user!, only: %i[join quite update destroy new approve reject]
  before_action :set_group
  before_action :set_group_user, only: %i[approve reject]

  def index
    params[:page] ||= 1
    @group_users = @group.group_users.order(:role).page(params[:page])
  end

  def update
    @group_user.update(group_user_params) if current_user.id == @group.user_id
  end

  def edit
  end

  def destroy
    @group_user.delete
  end

  def join
    @group_user = GroupUser.find_or_initialize_by(user_id: current_user.id, group_id: @group.id)
    @group_user.status = @group.public_group? ? 'accepted' : 'pendding'
    @group_user.save

    if @group.public_group?
      redirect_to(topics_group_path(@group), notice: t("groups.join_group_success"))
    elsif @group.private_group?
      redirect_to(group_path(@group), notice: t("groups.waiting_approvement"))
    end
  end

  def quite
    @group_user = GroupUser.find_or_initialize_by(user_id: current_user.id, group_id: @group.id)
    @group_user.delete

    redirect_to(groups_path, notice: t("groups.quite_group_success"))
  end

  def approve
    @group_user.update(status: 'accepted') if @group_user.pendding?
  end

  def reject
    @group_user.update(status: 'rejected') if @group_user.pendding?
  end

  private

  def set_group
    @group = Group.find_by(id: params[:group_id])
  end

  def set_group_user
    @group_user = GroupUser.find_by(:id)
  end

  def group_user_params
    params.require(:group_user).permit(:msg, :role)
  end
end
