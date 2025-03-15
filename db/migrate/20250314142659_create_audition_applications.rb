class CreateAuditionApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :audition_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :nationality
      t.float :height
      t.string :gender
      t.string :video_link
      t.string :website_link
      t.string :cv
      t.string :profile_image
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
