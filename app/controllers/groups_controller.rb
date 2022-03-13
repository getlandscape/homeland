# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show topics]
  before_action :set_group, except: %i[new index create]
  before_action :set_current_group_user

  def index
    params[:page] ||= 1
    params[:per] ||= 18
    @groups = Group.approved_groups
    @group = @groups.includes(:group_users).where(group_users: {user_id: current_user.id}) if current_user.present?
    @groups = @groups.order(:id).page(params[:page]).per(params[:per])
  end

  def show
    params[:page] ||= 1
    params[:per] ||= 27
    @group_users = GroupUser.where(group_id: @group.id).joins(:user).order(role: :asc, status: :asc).page(params[:page]).per(params[:per])
  end

  def new
    @group = Group.new
  end

  def edit
  end

  def create
    @group = Group.new(group_params)
    if @group.policy_agree
      if @group.save
        GroupUser.create(user_id: current_user.id, group_id: @group.id, role: :owner, status: :accepted)
        redirect_to(group_path(@group), notice: t("common.create_success"))
      end
    else
      @group.errors.add(:group, t('groups.check_agreements_and_policies'))
    end
  end

  def update
    @group.update(group_params)

    respond_to do |format|
      format.js
      format.html { redirect_to(edit_group_path(@group), notice: t("common.update_success")) }
    end
  end

  def destroy
  end

  def topics
    if @group.private_group? && !(@current_group_user.present? && @current_group_user.accepted?)
      redirect_to(group_path(@group), alert: t("groups.join_to_review"))
    end

    params[:page] ||= 1
    @topics = @group.topics.last_actived.page(params[:page])
    if @topics.count.zero?
      if @current_group_user.present? && @current_group_user.accepted?
        flash.now[:notice] = t('groups.post_topic')
      else
        flash.now[:notice] = t('groups.join_to_post_topic')
      end
    end
    @page_title = t("menu.groups")
  end

  private

  def set_group
    @group ||= Group.find(params[:id])
  end

  def set_current_group_user
    @current_group_user = GroupUser.find_by(user_id: current_user.id, group_id: @group.id) if @group.present? && current_user.present?
  end

  def group_params
    params.require(:group).permit(:name, :description, :avatar, :group_type, :need_approve, :show_members, :policy_agree)
  end
end
