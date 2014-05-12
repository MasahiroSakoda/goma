<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController

  # GET <%= route_url %>/new
  def new
    @<%= resource_name %> = <%= resource_class_name %>.new
  end

  # POST <%= route_url %>
  def create
    @<%= resource_name %> = <%= resource_class_name %>.find_by_identifier(params[:<%= goma_config.authentication_keys.to_field_name %>])
    @<%= resource_name %>.send_reset_password_instructions! if @<%= resource_name %>

    flash[:notice] = "You will receive an email with instructions about how to reset your password in a few minutes."
    redirect_to <%= login_url %>
  end

  # GET <%= route_url %>/1/edit
  def edit
    @reset_password_token = params[:id]
  end

  # PATCH/PUT <%= route_url %>/1
  def update
    @<%= resource_name %>, err = <%= resource_class_name %>.load_from_reset_password_token_with_error(params[:id])

    if @<%= resource_name %>
      @<%= resource_name %>.unlock_access! if @<%= resource_name %>.lockable? && @<%= resource_name %>.access_locked?
      @<%= resource_name %>.change_password!(params[:<%= goma_config.password_attribute_name %>], params[:<%= goma_config.password_attribute_name %>_confirmation])
      force_login(@<%= resource_name %>)
      <%= specify_scope_if_needed %>redirect_back_or_to root_url, notice: 'Your password was changed successfully. You are now logged in.'
    else
      if err == :token_expired
        flash.now[:alert] = "The password reset URL you visited has expired, please request a new one."
        render :new
      else
        flash.now[:alert] = "You can't access this page without comming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided."
        render :edit
      end
    end
  end
end
<% end -%>
