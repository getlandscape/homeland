# frozen_string_literal: true

require "test_helper"
require "oauth2"

class OAuth2Test < ActiveSupport::TestCase
  attr_accessor :password, :user, :app, :client

  setup do
    @password = "123123"
    @user = FactoryBot.create(:user, password: password, password_confirmation: password)
    @app = FactoryBot.create(:application)
    @client = OAuth2::Client.new(app.uid, app.secret) do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
  end

  test "auth_code" do
    grant = FactoryBot.create(:access_grant, application: app, redirect_uri: "#{app.redirect_uri}/callback")

    assert_changes -> { Doorkeeper::AccessToken.count }, 1 do
      @access_token = client.auth_code.get_token(grant.token, redirect_uri: grant.redirect_uri)
    end

    refute_nil @access_token.token

    # Refresh Token
    assert_changes -> { Doorkeeper::AccessToken.count }, 1 do
      @new_token = @access_token.refresh!
    end
    refute_nil @new_token.token
    refute_equal @access_token.token, @new_token.token
  end

  test "password get_token" do
    assert_changes -> { Doorkeeper::AccessToken.count }, 1 do
      @access_token = client.password.get_token(user.email, password)
    end
    refute_nil @access_token.token

    # Refresh Token
    assert_changes -> { Doorkeeper::AccessToken.count }, 1 do
      @new_token = @access_token.refresh!
    end

    refute_nil @new_token.token
    refute_equal @access_token.token, @new_token.token
  end
end
