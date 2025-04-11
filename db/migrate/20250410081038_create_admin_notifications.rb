class CreateAdminNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_notifications do |t|
      t.string :kind
      t.integer :value

      t.timestamps
    end
  end
end
