class AddGomaTo<%= table_name.camelize %> < ActiveRecord::Migration
  def up
    change_table(:<%= table_name %>) do |t|
<%= migration_data -%>

<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>

      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps
    end

<%= index_data -%>

  end

  def down
    # Please edit below
    raise ActiveRecord::IrreversibleMigration
  end
end
