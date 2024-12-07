# frozen_string_literal: true

module Companies
  class User < ApplicationRecord
    self.table_name = :companies_users

    READ = 'read'
    WRITE = 'write'

    belongs_to :company
    belongs_to :user
    belongs_to :invite

    enum :access, { READ => 0, WRITE => 1 }
  end
end
