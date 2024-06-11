class AddEmailToFeedbacks < ActiveRecord::Migration[7.1]
  def change
    add_column :feedbacks, :email, :text
    add_column :feedbacks, :answerable, :boolean, null: false, default: false
  end
end
