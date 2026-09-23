# Sincroniza os models relacionais (fonte da verdade) pro grafo (Apache AGE,
# via rails_age) — o grafo é sempre uma projeção derivada, nunca a origem do
# dado. Idempotente: rodar de novo não duplica nó nem aresta.
class GraphSync
  def self.call
    new.call
  end

  def call
    sync_subjects
    sync_prerequisites
    sync_questions
    sync_question_subjects
  end

  private

  def sync_subjects
    Subject::Subject.find_each { |subject| find_or_create_graph_subject(subject.nome) }
  end

  def sync_prerequisites
    Subject::SubjectPrerequisite.find_each do |link|
      find_or_create_requires(
        subject:      find_or_create_graph_subject(link.subject.nome),
        prerequisite: find_or_create_graph_subject(link.prerequisite.nome)
      )
    end
  end

  def sync_questions
    Question::Question.find_each { |question| find_or_create_graph_question(question.titulo) }
  end

  def sync_question_subjects
    Question::QuestionSubject.find_each do |link|
      find_or_create_has_subject(
        question: find_or_create_graph_question(link.question.titulo),
        subject:  find_or_create_graph_subject(link.subject.nome)
      )
    end
  end

  def find_or_create_graph_subject(nome)
    graph_subjects[nome] ||= Graph::Subject.find_by(nome: nome) || create!(Graph::Subject, nome: nome)
  end

  def find_or_create_graph_question(titulo)
    graph_questions[titulo] ||= Graph::Question.find_by(titulo: titulo) || create!(Graph::Question, titulo: titulo)
  end

  def find_or_create_requires(subject:, prerequisite:)
    Graph::Requires.find_by(start_node: subject, end_node: prerequisite) ||
      create!(Graph::Requires, start_node: subject, end_node: prerequisite)
  end

  def find_or_create_has_subject(question:, subject:)
    Graph::HasSubject.find_by(start_node: question, end_node: subject) ||
      create!(Graph::HasSubject, start_node: question, end_node: subject)
  end

  # rails_age não tem .create! — falha alto manualmente em vez de devolver
  # silenciosamente um registro inválido não persistido.
  def create!(klass, **attributes)
    record = klass.create(**attributes)
    raise "#{klass}: #{record.errors.full_messages.join(', ')}" if record.errors.any?

    record
  end

  def graph_subjects
    @graph_subjects ||= {}
  end

  def graph_questions
    @graph_questions ||= {}
  end
end
