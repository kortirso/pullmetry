class CreateFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :feedbacks do |t|
      t.bigint :user_id, null: false, index: true
      t.string :title
      t.text :description, null: false
      t.timestamps
    end
  end
end
