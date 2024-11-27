# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend
  include Authkeeper::ApplicationHelper

  def js_component(component_name, **props)
    content_tag(
      'div',
      id: props[:component_id],
      class: props[:component_class],
      data: {
        js_component: component_name,
        props: component_props(props),
        children: props[:children]&.to_json
      }.compact
    ) { '' }
  end

  # rubocop: disable Rails/OutputSafety
  def embedded_svg(filename, options={})
    asset = Rails.application.assets.find_asset(filename)

    if asset
      file = asset.source.force_encoding('UTF-8')
      doc = Nokogiri::HTML::DocumentFragment.parse file
      svg = doc.at_css 'svg'
      svg['class'] = options[:class] if options[:class].present?
    else
      svg = "<!-- SVG #{filename} not found -->"
    end

    raw svg
  end

  def embedded_svg_symbol(filename, symbol_name, options={})
    asset = Rails.application.assets.find_asset('icon_sprite.svg')

    if asset
      file = asset.source.force_encoding('UTF-8')
      doc = Nokogiri::HTML::DocumentFragment.parse file
      svg = doc.at_css "symbol##{symbol_name}"
      svg['class'] = options[:class] if options[:class].present?
    else
      svg = "<!-- SVG #{filename} not found -->"
    end

    raw svg.to_s.gsub('symbol', 'svg')
  end
  # rubocop: enable Rails/OutputSafety

  private

  def component_props(props)
    props
      .except(:component_id, :component_class, :children)
      .deep_transform_keys! { |key| key.to_s.camelize(:lower) }
      .to_json
  end
end
