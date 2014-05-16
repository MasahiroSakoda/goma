class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|

      # Password authenticatable
      t.string :username
      t.string :email
      t.string :encrypted_password

      # Confirmable
      t.string :unconfirmed_email
      t.string :confirmation_token
      t.datetime :confirmation_token_sent_at
      t.string :activated_at

      # Rememberable
      t.datetime :remember_created_at

      # Lockable
      t.integer :failed_attempts, default: 0, null: false
      t.datetime :locked_at
      t.string :unlock_token
      t.datetime :unlock_token_sent_at

      # Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_token_sent_at

      # Trackable
      t.integer :login_count, default: 0, null: false
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.string :last_login_ip

      t.timestamps
    end
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :unlock_token, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
