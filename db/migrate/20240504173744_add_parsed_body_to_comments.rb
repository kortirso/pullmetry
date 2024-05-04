class AddParsedBodyToComments < ActiveRecord::Migration[7.1]
  def change
    add_column :pull_requests_comments, :parsed_body, :jsonb
  end
end
