module SimpleLang

  class Context

    attr_reader :tables

    def initialize
      @tables = []
    end

    def initialize_copy(other)
      @tables = other.tables.dup
    end

    def push!(table = Hash.new)
      @tables = [table] + @tables
      self
    end

    def push(table = Hash.new)
      copied = dup
      copied.push!(table)
    end

    def has_key?(key)
      @tables.each do |table|
        if table.has_key?(key)
          return true
        end
      end
      false
    end

    def [](key)
      @tables.each do |table|
        if table.has_key?(key)
          return table[key]
        end
      end
      nil
    end

    def []=(key, value)
      @tables.each do |table|
        if table.has_key?(key)
          table[key] = value
          return
        end
      end
      if @tables.length > 0
        @tables.last[key] = value
      end
    end

  end

end