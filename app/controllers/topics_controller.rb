# frozen_string_literal: true

class TopicsController < ApplicationController
  include Topics::ListActions

  before_action :authenticate_user!, only: %i[new edit create update destroy
    favorite unfavorite follow unfollow
    action favorites vote mark join edit_activity manage_activity]
  load_and_authorize_resource only: %i[new edit create update destroy favorite unfavorite follow unfollow edit_activity manage_activity]
  before_action :set_topic, only: %i[edit read update destroy follow unfollow action ban vote mark join edit_activity manage_activity]
  before_action :set_user_topic, only: %i[show mark join edit_activity manage_activity]

  def index
    @suggest_topics = []
    if params[:page].to_i <= 1
      @suggest_topics = topics_scope.suggest.includes(:node).limit(3)
    end
    @topics = topics_scope.without_suggest.last_actived.includes(:node).page(params[:page])
    @page_title = t("menu.topics")
    @read_topic_ids = []
    if current_user
      @read_topic_ids = current_user.filter_readed_topics(@topics + @suggest_topics)
    end
  end

  def feed
    @topics = Topic.recent.without_ban.without_hide_nodes.includes(:node, :user, :last_reply_user).limit(20)
    render layout: false if stale?(@topics)
  end

  def node
    @node = Node.find(params[:id])
    @topics = topics_scope(@node.topics, without_nodes: false).last_actived.page(params[:page])
    @page_title = "#{@node.name} &raquo; #{t("menu.topics")}"
    @page_title = [@node.name, t("menu.topics")].join(" · ")
    render action: "index"
  end

  def node_feed
    @node = Node.find(params[:id])
    @topics = @node.topics.recent.limit(20)
    render layout: false
  end

  def show
    # @topic = Topic.unscoped.includes(:user).find(params[:id])
    @topic = Topic.unscoped.find(params[:id])
    render_404 if @topic.deleted? || private_group_validation

    @node = @topic.node
    @show_raw = params[:raw] == "1"
    @can_reply = can?(:create, Reply)

    @replies = Reply.unscoped.where(topic_id: @topic.id).order(:id).all
    @user_like_reply_ids = current_user&.like_reply_ids_by_replies(@replies) || []

    @has_followed = current_user&.follow_topic?(@topic)
    @has_favorited = current_user&.favorite_topic?(@topic)

    user_topics_detail
  end

  def read
    @topic.hits.incr(1)
    current_user&.read_topic(@topic)
    render plain: "1"
  end

  def new
    gon.option_placeholder = t('topics.form.option_name')
    @group = Group.find_by(id: params[:group_id]) if params[:group_id].present?
    @topic = Topic.new(user_id: current_user.id, topic_type: params[:topic_type] || 'topic')
    unless params[:node_id].blank?
      @topic.node_id = params[:node_id]
      @node = Node.find_by_id(params[:node_id])
      render_404 if @node.blank?
    end
  end

  def edit
    gon.option_placeholder = t('topics.form.option_name')
    @topic_options = @topic.topic_options
    @node = @topic.node
  end

  def create
    @group = Group.find(params[:topic][:group_id]) if params[:topic][:group_id].present?

    unless @group.present? && @group.group_member?(current_user)
      redirect_to(new_topic_path(group_id: params[:topic][:group_id], topic_type: params[:topic][:topic_type]), alert: t("groups.join_requirement"))
    end

    @topic = Topic.new(topic_params)

    if @topic.poll? && (topic_option_params.empty? || @topic.poll_title.blank?)
      @topic.errors.add ' ', t("topics.option_number_validation")
      return
    end

    @topic.user_id = current_user.id
    @topic.node_id = params[:node] || topic_params[:node_id]
    @topic.team_id = ability_team_id
    @topic.save
  end

  def preview
    @body = params[:body]

    respond_to do |format|
      format.json
    end
  end

  def update
    if @topic.poll? && (topic_option_params.empty? || @topic.poll_title.blank?)
      redirect_to(new_topic_path(@topic, group_id: @topic.group_id, topic_type: @topic.topic_type), alert: t("topics.option_number_validation"))
    end

    if can?(:change_node, @topic)
      @topic.node_id = topic_params[:node_id]

      if @topic.node_id_changed? && can?(:lock_node, @topic)
        # Lock node when admin update
        @topic.lock_node = true
      end
    end
    if @topic.update(topic_params.merge(team_id: ability_team_id))
      @topic.topic_options.where.not(id: topic_option_params.pluck('id')).destroy_all
      @topic.topic_options.create(topic_option_params.select{ |a| a['id'].nil? })
    end
  end

  def destroy
    @topic.destroy_by(current_user)

    if @topic.group_id.present?
      redirect_to(topics_group_path(@topic.group), notice: t("topics.delete_topic_success"))
    else
      redirect_to(topics_path, notice: t("topics.delete_topic_success"))
    end
  end

  def favorite
    current_user.favorite_topic(params[:id])
    render plain: "1"
  end

  def unfavorite
    current_user.unfavorite_topic(params[:id])
    render plain: "1"
  end

  def follow
    current_user.follow_topic(@topic)
    render plain: "1"
  end

  def unfollow
    current_user.unfollow_topic(@topic)
    render plain: "1"
  end

  def ban
    authorize! :ban, @topic
  end

  def action
    authorize! params[:type].to_sym, @topic

    case params[:type]
    when "excellent"
      @topic.excellent!
      redirect_to @topic, notice: t("topics.excellent_successfully")
    when "normal"
      @topic.normal!
      redirect_to @topic, notice: t("topics.normal_successfully")
    when "ban"
      params[:reason_text] ||= params[:reason] || ""
      @topic.ban!(reason: params[:reason_text].strip)
      redirect_to @topic, notice: t("topics.ban_successfully")
    when "close"
      @topic.close!
      redirect_to @topic, notice: t("topics.close_successfully")
    when "open"
      @topic.open!
      redirect_to @topic, notice: t("topics.reopen_successfully")
    end
  end

  def vote
    render_404 if @topic.deleted? || @topic.ended? || !group_member_validation

    current_user.user_topic_options.where(topic_id: @topic.id).delete_all
    current_user.user_topic_options.create(TopicOption.vote_params(@topic.id, params[:topic_option_ids]))
  end

  def mark
    render_404 if @topic.deleted? || !group_member_validation
    if @current_user_topic.is_marked
      @current_user_topic.is_marked = false
    else
      @current_user_topic.is_marked = true
    end
    @current_user_topic.save

    user_topics_detail
  end

  def join
    render_404 if @topic.deleted? || !group_member_validation

    if @current_user_topic.id.present? && @current_user_topic.joined?
      @current_user_topic.status = 'draft'
    elsif @topic.need_approve?
      @current_user_topic.status = 'pendding'
    else
      @current_user_topic.status = 'joined'
    end
    @current_user_topic.save

    user_topics_detail
  end

  def edit_activity
    render_404 if @topic.deleted?

    @user_topic = @topic.user_topics.find_by(id: params[:user_topic_id])

    user_topics_detail
  end

  def manage_activity
    render_404 if @topic.deleted?

    @user_topic = @topic.user_topics.find_by(id: params[:user_topic_id])
    case params[:opt]
    when 'approve'
      @user_topic.update(status: 'joined')
    when 'reject'
      @user_topic.destroy
    end

    user_topics_detail
  end

  private

  def set_topic
    @topic ||= Topic.find(params[:id])
  end

  def set_user_topic
    @current_user_topic ||= UserTopic.find_or_initialize_by(topic_id: params[:id], user_id: current_user.id) if current_user.present?
  end

  def topic_params
    params.require(:topic)
          .permit(:title, :body, :node_id,
                  :team_id, :group_id, :topic_type,
                  :ends_at, :select_type, :poll_title,
                  :starts_at, :location, :show_members, :need_approve,
                  topic_options_attributes: [:id, :name])
  end

  def ability_team_id
    team = Team.find_by_id(topic_params[:team_id])
    return nil if team.blank?
    return nil if cannot?(:show, team)
    team.id
  end

  def private_group_validation
    group = @topic.group
    return false unless group.present? && group.private_group?
    return false if current_user.present? && group.group_member?(current_user)
    true
  end

  def group_member_validation
    group = @topic.group
    return true if current_user.present? && group.group_member?(current_user)
    false
  end

  def topic_option_params
    topic_params[:topic_options_attributes].to_h.values.select { |k| k[:name].present? }
  end

  def user_topics_detail
    if @topic.activity?
      params[:page] ||= 1
      params[:per] ||= 9
      @penddings = @topic.user_topics.pendding.page(params[:page]).per(params[:per])
      @none_penddings = @topic.user_topics.none_pendding
    end
  end
end
