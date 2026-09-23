namespace :graph do
  desc "Sincroniza os models relacionais pro grafo (Apache AGE)"
  task sync: :environment do
    GraphSync.call
    puts "Grafo sincronizado."
  end
end
