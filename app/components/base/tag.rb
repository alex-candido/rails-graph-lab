class Components::Base::Tag < Components::Base
  def initialize(label:, variant: :default, size: :default, **attributes)
    @label      = label
    @variant    = variant
    @size       = size
    @attributes = attributes
  end

  private

  def base_classes
    [ "inline-flex items-center rounded-full font-medium", variant_classes, size_classes ].join(" ")
  end

  def variant_classes
    case @variant
    when :primary, :default then "bg-primary-100 text-primary-700"
    when :success           then "bg-success-100 text-success-700"
    when :danger            then "bg-danger-100 text-danger-700"
    when :warning            then "bg-warning-100 text-warning-700"
    when :info              then "bg-info-100 text-info-700"
    when :gray               then "bg-gray-100 text-gray-700"
    else                          "bg-gray-100 text-gray-700"
    end
  end

  def size_classes
    case @size
    when :sm then "px-2 py-0.5 text-xs"
    when :lg then "px-3 py-1 text-sm"
    else          "px-2.5 py-0.5 text-xs"
    end
  end

  public

  def view_template
    span(**mix({ class: base_classes }, **@attributes)) { plain @label }
  end
end
