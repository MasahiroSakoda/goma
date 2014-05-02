class GomaCreate<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    create_table(:<%= table_name %>) do |t|
<%= migration_data -%>

<% attributes.each do |attribute| %>
      t.<%= attribute.type %> :<%= attribute.name %><%= attribute.inject_options %>
<% end -%>

      t.timestamps
    end

<%= index_data -%>

  end
end
