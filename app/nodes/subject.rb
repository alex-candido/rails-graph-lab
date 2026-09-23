class Subject
  include ApacheAge::Entities::Node

  attribute :nome, :string

  validates :nome, presence: true

  # custom unique node validator (remove any attributes that are NOT important to uniqueness)
  validates_with(
    ApacheAge::Validators::UniqueNode,
    attributes: [:nome]
  )
end
