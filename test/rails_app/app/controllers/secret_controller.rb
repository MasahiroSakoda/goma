class SecretController < ApplicationController
  before_action :require_login
  skip_trackable only: :not_track
  skip_timeout only: :not_timeout
  skip_validate_session only: :not_validate_session

  def index
    render text: 'index'
  end

  def an_action_constraints_current_user_with_arity_block
    render text: 'an action constraints current user with arity block'
  end

  def an_action_constraints_current_user_with_no_arity_block
    render text: 'an action constraints current user with no arity block'
  end

  def not_track
    render text: 'do not track this action'
  end

  def not_timeout
    render text: 'do not timeout in this action'
  end

  def not_validate_session
    render text: 'do not validate_session in this action'
  end
end
