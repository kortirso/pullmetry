# frozen_string_literal: true

class AddExcludesGroupCommand < BaseCommand
  use_contract do
    config.messages.namespace = :excludes_group

    Targets = Dry::Types['strict.string'].enum(*Excludes::Rule.targets.keys)
    Conditions = Dry::Types['strict.string'].enum(*Excludes::Rule.conditions.keys)

    params do
      required(:target).filled(Targets)
      required(:condition).filled(Conditions)
      required(:value).filled(:string)
    end
  end

  private

  def do_validate(input)
    error = validate_existing_groups_amount(input[:company])
    [error] if error
  end

  def do_prepare(input)
    input[:excludes_rules] = filter_rules(input[:excludes_rules])
    input
  end

  def do_persist(input)
    error = validate_valid_rules_amount(input)
    return { errors: [error] } if error

    excludes_group = Excludes::Group.create!(insightable: input[:company])

    Excludes::Rule.upsert_all(
      input[:excludes_rules].map { |excludes_rule| excludes_rule.merge(excludes_group_id: excludes_group.id) }
    )

    { result: excludes_group }
  end

  def validate_existing_groups_amount(company)
    return if company.premium?
    return if company.excludes_groups.size < Excludes::Group::FREE_GROUPS_AMOUNT

    "Maximum amount of groups is #{Excludes::Group::FREE_GROUPS_AMOUNT} for regular accounts"
  end

  def filter_rules(excludes_rules)
    excludes_rules.filter_map do |excludes_rule|
      errors = validate(excludes_rule.to_h)
      next if errors.any?

      excludes_rule.merge(uuid: SecureRandom.uuid)
    end
  end

  def validate_valid_rules_amount(input)
    return 'You must fully specify at least 1 rule' if input[:excludes_rules].empty?
    return if input[:company].premium?
    return if input[:excludes_rules].size <= Excludes::Rule::FREE_RULES_AMOUNT

    "Maximum amount of rules in group is #{Excludes::Rule::FREE_RULES_AMOUNT} for regular account"
  end
end
