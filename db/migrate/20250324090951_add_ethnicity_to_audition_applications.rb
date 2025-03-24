class AddEthnicityToAuditionApplications < ActiveRecord::Migration[7.1]
  def change
    add_reference :audition_applications, :ethnicity, null: true, foreign_key: true
  end
end
