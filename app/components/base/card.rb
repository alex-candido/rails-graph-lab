class Components::Base::Card < Components::Base
  def initialize(class: nil, padding: "px-6 py-4")
    @css     = binding.local_variable_get(:class)
    @padding = padding
  end

  private

  def card_classes
    [ "overflow-hidden rounded-xl bg-white shadow ring-1 ring-gray-950/5", @css ].compact.join(" ")
  end

  def header_classes
    "border-b border-gray-100 px-6 py-4"
  end

  def footer_classes
    "border-t border-gray-100 px-6 py-4"
  end

  public

  def header(**attributes, &block)
    div(**mix({ class: header_classes }, **attributes), &block)
  end

  def footer(**attributes, &block)
    div(**mix({ class: footer_classes }, **attributes), &block)
  end

  def view_template
    div(class: card_classes) do
      div(class: @padding) { yield(self) }
    end
  end
end
