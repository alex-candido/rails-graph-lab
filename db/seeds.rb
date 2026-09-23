# Cenário sintético: árvore de pré-requisito de Matemática + questões
# associadas a cada assunto — dado o suficiente pra testar travessia
# multi-salto de verdade (GraphRAG), não só um exemplo de brinquedo.

require "factory_bot"
FactoryBot.definition_file_paths = [ Rails.root.join("db/factories").to_s ]
FactoryBot.find_definitions

CURRICULO = [
  { nome: "Aritmética Básica",   prerequisitos: [],                        questoes: [ "Quanto é 7 + 8 × 2?" ] },
  { nome: "Equações do 1º grau", prerequisitos: [ "Aritmética Básica" ],    questoes: [ "Resolva: 3x + 5 = 20" ] },
  { nome: "Equações do 2º grau", prerequisitos: [ "Equações do 1º grau" ], questoes: [ "Encontre as raízes de x² - 5x + 6 = 0" ] },
  { nome: "Álgebra",             prerequisitos: [ "Equações do 1º grau" ], questoes: [ "Simplifique a expressão 2(x + 3) - x" ] },
  { nome: "Funções",             prerequisitos: [ "Álgebra" ],
    questoes: [ "Dada f(x) = 2x + 1, calcule f(3)", "Qual o gráfico de f(x) = x² representa?" ] },
  { nome: "Área e Perímetro",    prerequisitos: [],
    questoes: [ "Calcule a área de um retângulo de lados 4cm e 7cm", "Calcule o perímetro de um triângulo de lados 3, 4 e 5" ] },
  { nome: "Geometria Plana",     prerequisitos: [ "Área e Perímetro" ],    questoes: [ "Some os ângulos internos de um pentágono regular" ] },
  { nome: "Trigonometria",       prerequisitos: [ "Geometria Plana" ],     questoes: [ "Calcule o seno de 30°" ] }
].freeze

def find_or_create_subject(nome)
  Subject::Subject.find_by(nome: nome) || FactoryBot.create(:subject_subject, nome: nome)
end

def link_prerequisite(subject:, prerequisite:)
  Subject::SubjectPrerequisite.find_or_create_by!(subject: subject, prerequisite: prerequisite)
end

def find_or_create_question(titulo)
  Question::Question.find_by(titulo: titulo) || FactoryBot.create(:question_question, titulo: titulo)
end

def link_question_subject(question:, subject:)
  Question::QuestionSubject.find_or_create_by!(question: question, subject: subject)
end

puts "Populando árvore de pré-requisito de Matemática..."

# 1ª passada: garante que todo assunto existe antes de ligar pré-requisito
# (evita depender da ordem em que aparecem no CURRICULO)
subjects_by_nome = CURRICULO.each_with_object({}) do |dados, memo|
  memo[dados[:nome]] = find_or_create_subject(dados[:nome])
end

# 2ª passada: liga pré-requisitos e questões de cada assunto
CURRICULO.each do |dados|
  subject = subjects_by_nome.fetch(dados[:nome])

  dados[:prerequisitos].each do |nome_prerequisito|
    link_prerequisite(subject: subject, prerequisite: subjects_by_nome.fetch(nome_prerequisito))
  end

  dados[:questoes].each do |titulo|
    question = find_or_create_question(titulo)
    link_question_subject(question: question, subject: subject)
  end
end

puts "Pronto: #{Subject::Subject.count} assuntos, #{Question::Question.count} questões, " \
     "#{Subject::SubjectPrerequisite.count} pré-requisitos, #{Question::QuestionSubject.count} vínculos questão-assunto."

puts "Sincronizando pro grafo..."
GraphSync.call
puts "Grafo sincronizado: #{Graph::Subject.all.to_a.size} nós Subject, #{Graph::Question.all.to_a.size} nós Question."
