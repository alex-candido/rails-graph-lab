# Sincroniza os models relacionais (fonte da verdade) pro grafo (Apache AGE,
# via rails_age) — o grafo é sempre uma projeção derivada, nunca a origem do
# dado. Idempotente: rodar de novo não duplica nó nem aresta.
class GraphSync
  # Chave fixa e arbitrária pro lock consultivo do Postgres — só precisa ser
  # sempre a mesma, pra travar qualquer execução concorrente desta classe
  # (seja em threads do mesmo processo — adapter :async — seja em processos
  # distintos, como workers reais do Solid Queue em produção).
  ADVISORY_LOCK_KEY = 8_004_200_727

  def self.call
    new.call
  end

  def call
    with_advisory_lock do
      sync_subjects
      sync_prerequisites
      sync_questions
      sync_question_subjects
      prune_orphan_subjects
      prune_orphan_questions
    end
  end

  private

  # find_by || create não é atômico — duas execuções concorrentes podem
  # "não achar" e criar duplicado ao mesmo tempo (foi exatamente o que
  # aconteceu: "Álgebra" duplicou quando o job assíncrono de cada criação do
  # seed rodou junto com a chamada explícita no final). O lock consultivo
  # do Postgres serializa qualquer chamada a GraphSync.call, em qualquer
  # processo, eliminando a corrida.
  #
  # Usa a variante _xact (escopo de transação, libera sozinha no COMMIT) em
  # vez de pg_advisory_lock/unlock manual — a versão manual depende de
  # travar e destravar exatamente na mesma conexão física, e sob o adapter
  # :async (threads concorrentes disputando conexões do pool) isso gerava
  # "WARNING: you don't own a lock of type ExclusiveLock" quando o unlock
  # calhava de rodar numa conexão diferente da que travou.
  def with_advisory_lock
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("SELECT pg_advisory_xact_lock(#{ADVISORY_LOCK_KEY})")
      yield
    end
  end

  def sync_subjects
    Subject::Subject.find_each { |subject| find_or_create_graph_subject(subject.nome) }
  end

  # Remove do grafo qualquer nó cujo registro relacional correspondente não
  # existe mais (ex.: Subject::Subject apagado) — sem isso, apagar no
  # relacional deixava o nó pra trás pra sempre.
  def prune_orphan_subjects
    existing_names = Subject::Subject.pluck(:nome)
    Graph::Subject.all.each { |node| node.destroy unless existing_names.include?(node.nome) }
  end

  def prune_orphan_questions
    existing_titles = Question::Question.pluck(:titulo)
    Graph::Question.all.each { |node| node.destroy unless existing_titles.include?(node.titulo) }
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
