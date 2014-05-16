class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :provider
      t.string :uid
      t.belongs_to :user, index: true

      t.timestamps
    end
    add_index :authentications, [:provider, :uid], unique: :true
  end
end
