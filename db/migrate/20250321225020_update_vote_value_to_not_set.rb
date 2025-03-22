class UpdateVoteValueToNotSet < ActiveRecord::Migration[7.1]
  def change
    Vote.where(vote_value: 0).update_all(vote_value: 0)
  end
end
