class AuthenticationsController < ApplicationController
  before_action
  # GET  auth/:provider/callback
  # POST /authentications
  def create
    authentication = Authentication.find_by(provider: omniauth[:provider], uid: omniauth[:uid])
    if authentication
      user = authentication.user
    else
      user = User.create_with_omniauth!(omniauth)
    end
    force_login(user)
    redirect_back_or_to root_url, notice: "Successfully authenticated from #{omniauth[:provider]} account."
  end
end
