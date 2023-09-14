class AddChangedLocToPullRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :pull_requests, :changed_loc, :integer, null: false, default: 0, comment: 'Lines Of Code changed in pull request'
  end
end
