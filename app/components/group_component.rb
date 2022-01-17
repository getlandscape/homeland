# frozen_string_literal: true

class GroupComponent < ApplicationComponent
  attr_reader :group, :current_user

  with_collection_parameter :group

  def initialize(group:, current_user:)
    @group = group
    @current_user = current_user
  end

  def render?
    !!@group
  end
end
