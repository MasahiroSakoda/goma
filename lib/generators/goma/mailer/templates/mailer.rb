<% module_namespacing do -%>
class <%= class_name %> < ActionMailer::Base
  default from: "from@example.com"

<% goma_actions.each do |action, subject| -%>
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.<%= file_path.tr("/",".") %>.<%= action %>.subject
  #
  def <%= goma_config.send("#{action}_method_name") %>(<%= resource_name %>)
    @<%= resource_name %> = <%= resource_name %>
    mail to: @<%= resource_name %>.<%= goma_config.email_attribute_name %>,
         subject: "<%= subject %>"
  end
<% end -%>


<% actions.each do |action| -%>

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.<%= file_path.tr("/",".") %>.<%= action %>.subject
  #
  def <%= action %>
    @greeting = "Hi"

    mail to: "to@example.org"
  end
<% end -%>
end
<% end -%>
