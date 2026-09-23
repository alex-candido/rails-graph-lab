# Cenário sintético: árvore de pré-requisito de Matemática + questões
# associadas a cada assunto — dado o suficiente pra testar travessia
# multi-salto de verdade (GraphRAG), não só um exemplo de brinquedo.

require "factory_bot"
FactoryBot.definition_file_paths = [ Rails.root.join("db/factories").to_s ]
FactoryBot.find_definitions

def subject!(nome)
  Subject::Subject.find_by(nome: nome) || FactoryBot.create(:subject_subject, nome: nome)
end

def requires!(subject:, prerequisite:)
  Subject::SubjectPrerequisite.find_or_create_by!(subject: subject, prerequisite: prerequisite)
end

def question!(titulo, subject:)
  q = Question::Question.find_by(titulo: titulo) || FactoryBot.create(:question_question, titulo: titulo)
  Question::QuestionSubject.find_or_create_by!(question: q, subject: subject)
  q
end

puts "Populando árvore de pré-requisito de Matemática..."

aritmetica     = subject!("Aritmética Básica")
equacoes_1grau = subject!("Equações do 1º grau")
equacoes_2grau = subject!("Equações do 2º grau")
algebra        = subject!("Álgebra")
funcoes        = subject!("Funções")
area_perimetro = subject!("Área e Perímetro")
geometria      = subject!("Geometria Plana")
trigonometria  = subject!("Trigonometria")

requires!(subject: equacoes_1grau, prerequisite: aritmetica)
requires!(subject: equacoes_2grau, prerequisite: equacoes_1grau)
requires!(subject: algebra,        prerequisite: equacoes_1grau)
requires!(subject: funcoes,        prerequisite: algebra)
requires!(subject: geometria,      prerequisite: area_perimetro)
requires!(subject: trigonometria,  prerequisite: geometria)

question!("Quanto é 7 + 8 × 2?", subject: aritmetica)
question!("Resolva: 3x + 5 = 20", subject: equacoes_1grau)
question!("Encontre as raízes de x² - 5x + 6 = 0", subject: equacoes_2grau)
question!("Simplifique a expressão 2(x + 3) - x", subject: algebra)
question!("Dada f(x) = 2x + 1, calcule f(3)", subject: funcoes)
question!("Qual o gráfico de f(x) = x² representa?", subject: funcoes)
question!("Calcule a área de um retângulo de lados 4cm e 7cm", subject: area_perimetro)
question!("Calcule o perímetro de um triângulo de lados 3, 4 e 5", subject: area_perimetro)
question!("Some os ângulos internos de um pentágono regular", subject: geometria)
question!("Calcule o seno de 30°", subject: trigonometria)

puts "Pronto: #{Subject::Subject.count} assuntos, #{Question::Question.count} questões, " \
     "#{Subject::SubjectPrerequisite.count} pré-requisitos, #{Question::QuestionSubject.count} vínculos questão-assunto."
