class RemoveWebsiteLinkFromAuditionApplications < ActiveRecord::Migration[7.1]
  def change
    remove_column :audition_applications, :website_link, :string
  end
end
