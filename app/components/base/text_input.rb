class Components::Base::TextInput < Components::Base
  INPUT_CLASS = "block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm text-gray-900 shadow-sm placeholder:text-gray-400 focus:border-primary-500 focus:ring-2 focus:ring-primary-500/20 focus:outline-none"
  LABEL_CLASS = "block text-sm font-medium text-gray-700 mb-1"

  def self.input_class = INPUT_CLASS
  def self.label_class = LABEL_CLASS
end
