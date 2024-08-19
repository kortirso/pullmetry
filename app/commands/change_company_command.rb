# frozen_string_literal: true

class ChangeCompanyCommand < BaseCommand
  use_contract do
    params do
      required(:company).filled(type?: Company)
      optional(:accessable).filled(:bool)
      optional(:not_accessable_ticks).filled(:integer)
    end
  end

  private

  def do_persist(input)
    input[:company].update!(input.except(:company))

    { result: input[:company].reload }
  end
end
