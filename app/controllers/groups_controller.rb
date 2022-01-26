# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :authenticate_user!, only: %i[new edit create update destroy]
  before_action :set_group, only: %i[show edit update destroy join quite topics]

  def index
    params[:page] ||= 1
    @groups = Group.approved_groups.includes(:group_users).order(:id).page(params[:page])
  end

  def show
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

    redirect_to(edit_group_path(@group), notice: t("common.update_success"))
  end

  def destroy
  end

  def topics
    params[:page] ||= 1
    @topics = @group.topics.last_actived.page(params[:page])
    @page_title = t("menu.groups")
  end

  private

  def set_group
    @group ||= Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :description, :avatar, :group_type, :auto_approvce, :show_members, :policy_agree)
  end
end
