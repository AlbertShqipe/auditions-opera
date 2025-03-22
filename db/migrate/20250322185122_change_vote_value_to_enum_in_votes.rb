class ChangeVoteValueToEnumInVotes < ActiveRecord::Migration[7.1]
  def change
    change_column :votes, :vote_value, :integer, using: 'vote_value::integer', default: 0
  end
end
