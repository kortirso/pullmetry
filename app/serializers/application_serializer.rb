# frozen_string_literal: true

class ApplicationSerializer
  include JSONAPI::Serializer

  set_id { SecureRandom.hex }

  def self.required_field?(params, field_name)
    params[:include_fields]&.include?(field_name) || params[:exclude_fields]&.exclude?(field_name)
  end
end
