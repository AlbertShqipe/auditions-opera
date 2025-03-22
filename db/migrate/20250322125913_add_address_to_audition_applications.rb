class AddAddressToAuditionApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :audition_applications, :address, :string
  end
end
