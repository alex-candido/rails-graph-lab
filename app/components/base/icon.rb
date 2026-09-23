class Components::Base::Icon < Components::Base
  ICONS = {
    home: [
      "m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"
    ],
    user: [
      "M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"
    ],
    magnifying_glass: [
      "m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"
    ],
    paper_clip: [
      "m18.375 12.739-7.693 7.693a4.5 4.5 0 0 1-6.364-6.364l10.94-10.94A3 3 0 1 1 19.5 7.372L8.552 18.32m.009-.01-.01.01m5.699-9.941-7.81 7.81a1.5 1.5 0 0 0 2.112 2.13"
    ],
    check_circle: [
      "M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
    ],
    x_circle: [
      "M15 9 9 15m6 0-6-6M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
    ],
    chevron_down: [
      "m19.5 8.25-7.5 7.5-7.5-7.5"
    ]
  }.freeze

  def initialize(name, size: :md, css: nil)
    @name = name.to_sym
    @size = size
    @css = css
  end

  def view_template
    paths = ICONS.fetch(@name) { raise ArgumentError, "Unknown icon: #{@name}. Available: #{ICONS.keys.join(', ')}" }

    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: @css || size_class
    ) do |s|
      paths.each do |d|
        s.path(stroke_linecap: "round", stroke_linejoin: "round", d: d)
      end
    end
  end

  private

  def size_class
    case @size
    when :xs then "size-3"
    when :sm then "size-4"
    when :md then "size-5"
    when :lg then "size-6"
    when :xl then "size-8"
    else "size-5"
    end
  end
end
