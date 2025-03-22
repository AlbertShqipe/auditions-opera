class RenameValueToVoteValueInVotes < ActiveRecord::Migration[7.1]
  def change
    rename_column :votes, :value, :vote_value
  end
end
