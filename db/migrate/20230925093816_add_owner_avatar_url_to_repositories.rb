class AddOwnerAvatarUrlToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :owner_avatar_url, :string
  end
end
