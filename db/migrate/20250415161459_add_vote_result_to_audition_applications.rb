class AddVoteResultToAuditionApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :audition_applications, :vote_result, :string
  end
end
