# frozen_string_literal: true

module Excludes
  class Rule < ApplicationRecord
    self.table_name = :excludes_rules

    include Uuidable

    FREE_RULES_AMOUNT = 3

    TITLE_TARGET = 'title'
    DESCRIPTION_TARGET = 'description_target'
    BRANCH_NAME_TARGET = 'branch_name'
    DESTINATION_BRANCH_NAME_TARGET = 'destination_branch_name'

    EQUAL_CONDITION = 'equal'
    NOT_EQUAL_CONDITION = 'not_equal'
    CONTAIN_CONDITION = 'contain'
    NOT_CONTAIN_CONDITION = 'not_contain'

    belongs_to :excludes_group, class_name: 'Excludes::Group'

    enum :target, {
      TITLE_TARGET => 0,
      DESCRIPTION_TARGET => 1,
      BRANCH_NAME_TARGET => 2,
      DESTINATION_BRANCH_NAME_TARGET => 3
    }

    enum :condition, {
      EQUAL_CONDITION => 0,
      NOT_EQUAL_CONDITION => 1,
      CONTAIN_CONDITION => 2,
      NOT_CONTAIN_CONDITION => 3
    }
  end
end
