class HasSubject
  include ApacheAge::Entities::Edge

  attribute :start_node, :question
  attribute :end_node, :subject

  validates :start_node, presence: true
  validates :end_node, presence: true

  validate :validate_unique_edge

  private

  # custom unique edge validator (remove any attributes that are NOT important to uniqueness)
  def validate_unique_edge
    ApacheAge::Validators::UniqueEdge
      .new(attributes: [:start_node, :end_node])
      .validate(self)
  end
end
