<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  # GET <%= route_url %>/new
  def new
    @<%= resource_name %>= <%= resource_class_name %>.new
  end


  # POST <%= route_url %>
  def create
    @<%= resource_name %> = <%= resource_class_name %>.find_by_identifier(params[:<%= goma_config.authentication_keys.to_field_name %>])
    @<%= resource_name %>.resend_activation_needed_email

    redirect_to <%= login_url %>, notice: "We are processing your request. You will receive new activation email in a few minutes."
  end


  # GET <%= route_url %>/1
  def show
    @<%= resource_name %>, err = <%= resource_class_name %>.load_from_activation_token_with_error(params[:id])

    if @<%= resource_name %>
      @<%= resource_name %>.activate!
      redirect_to <%= login_url %>, notice: 'Your account was successfully activated.'
    else
      if err == :token_expired
        flash.now[:alert] = "Your activation URL has expired, please request a new one."
      else
        flash.now[:alert] = "Not found any account by this URL. Please make sure you used the full URL provided."
      end
      render :new
    end
  end


  # GET <%= route_url %>/1/email
  def email
    @<%= resource_name %>, err = <%= resource_class_name %>.load_from_email_confirmation_token_with_error(params[:id])

    if @<%= resource_name %>
      @<%= resource_name %>.confirm_email!
      redirect_to root_url, notice: 'Your new email was successfully confirmed.'
    else
      if err == :token_expired
        flash.now[:alert] = "Your email confirmation URL has expired, please change your email again."
      else
        flash.now[:alert] = "Email confirmation failed. Please make sure you used the full URL provided."
      end

      if current_<%= resource_name %>
        render edit_<%= resource_name%>_url(current_<%= resource_name %>)
      else
        render root_url
      end
    end
  end
end
<% end -%>
