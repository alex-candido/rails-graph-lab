class Components::Base::ReactComponent < Components::Base
  def initialize(name:, props: {})
    @name = name
    @props = props
  end

  def view_template(&block)
    div("data-controller": "react",
        "data-react-component-value": @name,
        "data-react-props-value": @props.to_json,
        &block)
  end
end
