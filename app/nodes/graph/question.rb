module Graph
  class Question
    include ApacheAge::Entities::Node

    attribute :titulo, :string

    validates :titulo, presence: true

    # custom unique node validator (remove any attributes that are NOT important to uniqueness)
    validates_with(
      ApacheAge::Validators::UniqueNode,
      attributes: [:titulo]
    )
  end
end
