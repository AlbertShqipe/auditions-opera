class SetUndefinedForExistingVotes < ActiveRecord::Migration[7.1]
  def change
    Vote.where(vote_value: nil).update_all(vote_value: :undefined)
  end
end
