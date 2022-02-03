# frozen_string_literal: true

class GroupUsersController < ApplicationController
  before_action :authenticate_user!, except: %i[index]
  before_action :set_group
  before_action :set_group_user, except: %i[index new create destroy]

  def index
    params[:page] ||= 1
    @group_users = @group.group_users.order(:role).page(params[:page])
  end

  def show
  end

  def new
    @group_user = GroupUser.find_or_initialize_by(user_id: current_user.id, group_id: params[:group_id])
  end

  def create
    @group_user = GroupUser.find_or_initialize_by(user_id: current_user.id, group_id: @group.id)
    @group_user.role = 'member'
    @group_user.status = @group.public_group? ? 'accepted' : 'pendding'
    @group_user.save

    if @group.public_group?
      redirect_to(topics_group_path(@group), notice: t("groups.join_group_success"))
    elsif @group.private_group?
      redirect_to(group_path(@group), notice: t("groups.waiting_approvement"))
    end
  end

  def edit
    @group_user = current_user.group_users.find_by(id: params[:id])
  end

  def update
    @current_group_user = GroupUser.find_by(user_id: current_user.id, group_id: @group.id)
    if @group.group_admin?(current_user)
      case params[:opt]
      when 'approve'
        @group_user.update(status: 'accepted')
      when 'upgrade'
        @group_user.update(status: 'accepted', role: 'admin') if @current_group_user.owner?
      when 'downgrade'
        @group_user.update(status: 'accepted', role: 'member') if @current_group_user.owner?
      else
        @group_user.delete if @current_group_user.read_attribute_before_type_cast(:role) < @group_user.read_attribute_before_type_cast(:role)
      end
    end
    params[:page] ||= 1
    params[:per] ||= 27
    @group_users = GroupUser.where(group_id: @group.id).joins(:user).order(role: :asc, status: :asc).page(params[:page]).per(params[:per])
  end

  def destroy
    @group_user = current_user.group_users.find_by(id: params[:id])
    if @group_user.delete
      redirect_to(groups_path, notice: t("groups.quite_group_success"))
    end
  end

  private

  def set_group
    @group = Group.find_by(id: params[:group_id])
  end

  def set_group_user
    @group_user = @group.group_users.find_by(id: params[:id])
  end

  def group_user_params
    params.require(:group_user).permit(:msg, :role)
  end
end
