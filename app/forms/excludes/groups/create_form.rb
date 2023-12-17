# frozen_string_literal: true

module Excludes
  module Groups
    class CreateForm
      include Deps[validator: 'validators.excludes.rules.create']

      def call(company:, excludes_rules: [])
        return { errors: ['Maximum amount of groups is 2 for regular accounts'] } unless groups_size_valid?(company)

        objects = validate_rules(excludes_rules)
        return { errors: ['You must fully specify at least 1 rule'] } if objects.empty?

        unless rules_size_valid?(company, objects)
          return { errors: ['Maximum amount of rules in group is 3 for regular account'] }
        end

        excludes_group = company.excludes_groups.create!
        Excludes::Rule.upsert_all(objects.map { |object| object.merge(excludes_group_id: excludes_group.id) })
        { result: excludes_group }
      end

      private

      def groups_size_valid?(company)
        return true if company.premium?

        company.excludes_groups.size < Excludes::Group::FREE_GROUPS_AMOUNT
      end

      def rules_size_valid?(company, objects)
        return true if company.premium?

        objects.size <= Excludes::Rule::FREE_RULES_AMOUNT
      end

      def validate_rules(excludes_rules)
        excludes_rules.filter_map do |excludes_rule|
          errors = validator.call(params: excludes_rule)
          next if errors.any?

          excludes_rule.merge(uuid: SecureRandom.uuid)
        end
      end
    end
  end
end
