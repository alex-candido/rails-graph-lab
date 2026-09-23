module ApacheAge
  # Bug real da gem rails_age (0.7.0): a cláusula MATCH gerada pra travessia
  # filtrando por tipo de aresta esquece o `:` antes do label — em Cypher,
  # `-[NomeDaAresta]->` sem os dois-pontos é interpretado como nome de
  # VARIÁVEL, não como filtro de tipo. Ou seja, `path_edge:` nunca filtrava
  # de verdade: `ApacheAge::Path.cypher(path_edge: Graph::HasSubject, ...)`
  # retornava caminhos de QUALQUER tipo de aresta, não só HasSubject.
  #
  # Confirmado rodando o Cypher gerado direto no Postgres/AGE, sem a gem no
  # meio — com `-[Graph__HasSubject]->` (sem `:`) o AGE devolve arestas
  # Requires misturadas; com `-[:Graph__HasSubject]->` (sintaxe correta),
  # só HasSubject.
  #
  # Corrige inserindo o `:` que falta, sem duplicar a lógica inteira do
  # método original.
  module PathEdgeLabelFix
    def cypher(**kwargs)
      result = super
      @match_clause = @match_clause.sub("[#{@path_edge}", "[:#{@path_edge}") if @path_edge.present? && @match_clause
      @query_builder.match_clause = @match_clause if @query_builder && @match_clause
      result
    end

    def match_clause
      original = super
      return original if @path_edge.blank? || @has_edge_ordering

      original.sub("[#{@path_edge}", "[:#{@path_edge}")
    end
  end
end
