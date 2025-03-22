class SetVoteValueToNotSetForAllAuditionApplications < ActiveRecord::Migration[7.1]
  def up
    AuditionApplication.find_each do |application|
      application.votes.update_all(vote_value: 0)  # 0 is the value for 'not_set' in the enum
    end
  end
end
