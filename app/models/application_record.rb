# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include Commento::Helpers

  # same as pluck but returns hash
  # User.where('id < 3').hashable_pluck(:id, :email)
  def self.hashable_pluck(*column_names)
    convert_values_to_array = column_names.size == 1

    symbolized_column_names = column_names.map do |column_name|
      next column_name.split('.').join('_').to_sym if column_name.is_a?(String)

      column_name
    end

    pluck(*column_names).map do |values|
      values = [values] if convert_values_to_array

      [symbolized_column_names, values].transpose.to_h
    end
  end
end
