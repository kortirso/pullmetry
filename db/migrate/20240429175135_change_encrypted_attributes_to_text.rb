class ChangeEncryptedAttributesToText < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      change_column :users, :email, :text
      change_column :subscribers, :email, :text
      change_column :invites, :email, :text
      change_column :identities, :email, :text
      change_column :access_tokens, :value, :text
    end
  end

  def down
    safety_assured do
      # encrypted value could have length more than 255 symbols
      User.find_each(&:decrypt)
      Subscriber.find_each(&:decrypt)
      Invite.find_each(&:decrypt)
      Identity.find_each(&:decrypt)
      AccessToken.find_each(&:decrypt)

      change_column :users, :email, :string
      change_column :subscribers, :email, :string
      change_column :invites, :email, :string
      change_column :identities, :email, :string
      change_column :access_tokens, :value, :string
    end
  end
end
