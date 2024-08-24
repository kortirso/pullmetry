# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend
  include Authkeeper::ApplicationHelper

  # def react_component(component_name, **props)
  #   content_tag(
  #     'div',
  #     id: props[:component_id],
  #     class: props[:component_class],
  #     data: {
  #       react_component: component_name,
  #       props: props.except(:component_id, :component_class, :children).to_json
  #     }
  #   ) { props[:children]&.to_json || '' }
  # end

  def js_component(component_name, **props)
    content_tag(
      'div',
      id: props[:component_id],
      class: props[:component_class],
      data: {
        js_component: component_name,
        props: props.except(:component_id, :component_class).to_json,
        children: props[:children]&.to_json || ''
      }
    ) { '' }
  end
end
