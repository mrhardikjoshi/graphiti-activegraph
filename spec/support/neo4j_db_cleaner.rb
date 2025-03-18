class Neo4jDbCleaner
  class << self
    def start
    end

    def clean
      ActiveGraph::Base.query('MATCH (n) DETACH DELETE n')
    end

    def cleaning(&block)
      start
      yield
      clean
    end
  end
end
