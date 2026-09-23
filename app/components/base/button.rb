class Components::Base::Button < Components::Base
  def initialize(label: nil, icon: nil, tag: :button, type: :button, variant: :primary, size: :default, path: nil, method: nil, form_class: nil, **attributes)
    @label      = label
    @icon       = icon
    @tag        = tag
    @type       = type
    @variant    = variant
    @size       = size
    @path       = path
    @method     = method
    @form_class = form_class
    @attributes = attributes
  end

  private

  def base_classes
    [ "inline-flex items-center gap-2", variant_classes, size_classes, "transition-colors cursor-pointer focus:outline-none" ].compact.join(" ")
  end

  def variant_classes
    case @variant
    when :primary
      "rounded-lg bg-primary-600 text-white font-semibold shadow-sm hover:bg-primary-500 focus:ring-2 focus:ring-primary-500/20"
    when :secondary
      "rounded-lg bg-white text-gray-700 font-semibold shadow-sm ring-1 ring-gray-300 hover:bg-gray-50 focus:ring-2 focus:ring-primary-500/20"
    when :danger
      "rounded-lg bg-danger-600 text-white font-semibold shadow-sm hover:bg-danger-500 focus:ring-2 focus:ring-danger-500/20"
    when :ghost
      "rounded-lg text-gray-500 hover:text-gray-700 hover:bg-gray-100 focus:ring-2 focus:ring-gray-500/20"
    when :link
      "text-primary-600 hover:text-primary-500 underline decoration-2"
    else
      "rounded-lg bg-primary-600 text-white font-semibold shadow-sm hover:bg-primary-500 focus:ring-2 focus:ring-primary-500/20"
    end
  end

  def size_classes
    case @size
    when :lg   then "px-5 py-3 text-base"
    when :sm   then "px-3 py-1.5 text-sm"
    when :xs   then "px-2.5 py-1 text-xs"
    when :icon then "size-8 justify-center"
    else            "px-4 py-2.5 text-sm"
    end
  end

  def render_content(&block)
    render(Components::Base::Icon.new(@icon, size: :sm)) if @icon
    if @label
      plain @label
    elsif block_given?
      yield
    end
  end

  public

  def view_template(&block)
    case @tag
    when :link
      link_to(@path, **mix({ class: base_classes }, **@attributes)) do
        render_content(&block)
      end
    when :button_to
      button_to(@path, method: @method || :post, form_class: @form_class, **mix({ class: base_classes }, **@attributes)) do
        render_content(&block)
      end
    else
      button(type: @type, **mix({ class: base_classes }, **@attributes)) do
        render_content(&block)
      end
    end
  end
end
