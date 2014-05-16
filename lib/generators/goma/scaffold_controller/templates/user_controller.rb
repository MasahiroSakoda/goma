<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action <%= (singular_table_name == Goma.config.default_scope && !Helpers.include_scope_name_into_controller_name) ? ':require_login' : ":require_#{singular_table_name}_login" %>, only: [:edit, :update, :destroy]
  before_action :set_<%= singular_table_name %>, only: [:show, :edit, :update, :destroy]

  # GET <%= route_url %>
  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
  end

  # GET <%= route_url %>/1
  def show
  end

  # GET <%= route_url %>/new
  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
  end

  # GET <%= route_url %>/1/edit
  def edit
    <%= goma_config.not_authenticated_action %> unless current_user = @user
  end

  # POST <%= route_url %>
  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>

    if @<%= orm_instance.save %>
<% if goma_config.modules.include?(:confirmable) && goma_config.allow_unactivated_access_for == 0 -%>
      redirect_to <%= login_url %>, notice: "You have signed up successfully. However, we could not sign you in because your account is not yet activated. You will receive an email with instructions about how to activate your account in a few minutes."
<% else -%>
      force_login(@<%= singular_table_name %>)
      redirect_back_or_to root_url, notice: "Welcome! You have signed up successfully.<%= goma_config.modules.include?(:confirmable) ? ' You will receive an email with instructions about how to activate your account in a few minutes.' : '' %>"
<% end -%>
    else
<% if goma_config.modules.include?(:confirmable) &&
     (auth_keys = goma_config.authentication_keys - [goma_config.email_attribute_name]).present? -%>
      update_email or render :new
<% else -%>
      render :new
<% end -%>
    end
  end

  # PATCH/PUT <%= route_url %>/1
  def update
    <%= goma_config.not_authenticated_action %> unless current_user = @user
    if @<%= orm_instance.update("#{singular_table_name}_params") %>
<% if goma_config.modules.include?(:confirmable) && goma_config.email_confirmation_enabled -%>
      flash[:notice] = @<%= singular_table_name %>.<%= goma_config.confirmation_token_to_send_attribute_name %> ?
                       'You updated your account successfully, but we need to verify your new email address. Please check your email and click on the confirmation link to finalize confirming your new email address.' :
                       'You updated your account successfully'
      redirect_to @<%= singular_table_name %>
<% else -%>
      redirect_to @<%= singular_table_name %>, notice:'You updated your account successfully'
<% end -%>
    else
      render :edit
    end
  end

  # DELETE <%= route_url %>/1
  def destroy
    <%= goma_config.not_authenticated_action %> unless current_user = @user
    @<%= orm_instance.destroy %>
    redirect_to <%= index_helper %>_url, notice: <%= "'#{human_name} was successfully destroyed.'" %>
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_<%= singular_table_name %>
      @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    end

    # Only allow a trusted parameter "white list" through.
    def <%= "#{singular_table_name}_params" %>
      params.require(:<%= singular_table_name %>).permit(<%= (resource_attributes + attributes_names).map { |name| ":#{name}" }.join(', ') %>)
    end
<% if goma_config.modules.include?(:confirmable) && auth_keys.present? -%>

    def update_email
<% if auth_keys.length == 1 -%>
      @<%= singular_table_name %> = <%= class_name %>.find_by(<%= auth_keys.first %>: params[:<%= singular_table_name %>][:<%= auth_keys.first %>])
<% else -%>
      [<%= auth_keys.map{|k| ":#{k}"}.join(', ') %>].each do |key|
        break if @<%= singular_table_name %> = <%= class_name %>.find_by(key => params[:<%= singular_table_name %>][key])
      end
<% end -%>
      if @<%= singular_table_name %>.activated?
        return false
      end

      if ( Time.now <= @<%= singular_table_name %>.<%= goma_config.confirmation_token_sent_at_attribute_name %> + <%= goma_config.activate_within %> ) &&
        !@<%= singular_table_name %>.valid_password?(params[:<%= singular_table_name %>][:<%= goma_config.password_attribute_name %>])
        flash[:alert] = 'This username was already registered. If you want to change your email address, please make sure you entered correct password.'
        return false
      end

      @<%= singular_table_name %>.resend_activation_needed_email(to: params[:<%= singular_table_name %>][:<%= goma_config.email_attribute_name %>])
      redirect_to <%= login_url %>
    end
<% end -%>
end
<% end -%>
