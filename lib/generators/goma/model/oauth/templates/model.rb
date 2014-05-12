<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
<% "Omit belongs_to line because it seems not be used in ordinary situation" -%>
end
<% end -%>
