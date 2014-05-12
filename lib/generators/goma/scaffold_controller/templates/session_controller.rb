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
<% if goma_config.modules.include? :confirmable -%>
     if @<%= resource_name %> = <%= resource_name %>_login(params[:<%= goma_config.authentication_keys.to_field_name %>], params[:<%= goma_config.password_attribute_name %>]<%= goma_config.modules.include?(:rememberable) ? ', params[:remember_me]' : '' %>)
      <%= specify_scope_if_needed %>redirect_back_or_to root_url, notice: 'Login successful'
    else
      if goma_error(:<%= resource_name %>) == :not_activated
        flash.now[:alert] = 'Not activated'
      else
        flash.now[:alert] = 'Login failed'
      end
      render :new
    end
<% else -%>
    if @<%= resource_name %> = <%= resource_name %>_login(params[:<%= goma_config.authentication_keys.to_field_name %>], params[:<%= goma_config.password_attribute_name %>])
      <%= specify_scope_if_needed %>redirect_back_or_to root_url, notice: 'Login successful'
    else
      flash.now[:alert] = 'Login failed'
      render :new
    end
<% end -%>
  end

  # DELETE <%= route_url %>
  def destroy
    <%= resource_name %>_logout
    redirect_to root_url, notice: "Logged out!"
  end
end
<% end -%>
