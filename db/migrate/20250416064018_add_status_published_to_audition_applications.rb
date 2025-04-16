class AddStatusPublishedToAuditionApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :audition_applications, :status_published, :boolean
  end
end
