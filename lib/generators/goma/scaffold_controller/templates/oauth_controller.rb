<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action
  # GET  auth/:provider/callback
  # POST <%= route_url %>
  def create
    <%= singular_table_name %> = <%= class_name %>.find_by(<%= goma_config.oauth_provider_attribute_name %>: omniauth[:provider], <%= goma_config.oauth_uid_attribute_name %>: omniauth[:uid])
    if <%= singular_table_name %>
      <%= resource_name %> = <%= singular_table_name %>.<%= resource_name %>
    else
      <%=resource_name %> = <%= resource_class_name %>.create_with_omniauth!(omniauth)
    end
    force_login(<%= resource_name %>)
    <%= specify_scope_if_needed %>redirect_back_or_to root_url, notice: "Successfully authenticated from #{omniauth[:provider]} account."
  end
end
<% end -%>
