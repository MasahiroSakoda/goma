<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController

  # GET <%= route_url %>/1
  def show
    @<%= resource_name %>, err = <%= resource_class_name %>.load_from_unlock_token_with_error(params[:id])
    if @<%= resource_name %>
      @<%= resource_name %>.unlock_access!
      flash[:notice] = "Your account has been unlocked successfully. Please continue to login."
      redirect_to <%= login_url %>
    else
      if err == :token_expired
        flash.now[:alert] = "The unlock URL you visited has expired, please request a new one."
      else
        flash.now[:alert] = "Not found any account by this URL."
      end
      render :new
    end
  end

  # GET <%= route_url %>/new
  def new
    @<%= resource_name %> = <%= resource_class_name %>.new
  end

  # POST <%= route_url %>
  def create
    @<%= resource_name %> = <%= resource_class_name %>.find_by_identifier(params[:<%= goma_config.authentication_keys.to_field_name %>])
    @<%= resource_name %>.send_unlock_instructions!

    flash[:notice] = 'Instructions have been sent to your email.'
    redirect_to <%= login_url %>
  end
end
<% end -%>
