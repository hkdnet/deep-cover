# frozen_string_literal: true

module DeepCover
  class Analyser::StatsBase
    include Memoize
    memoize :to_h, :total

    VALUES = %i[executed not_executed not_executable ignored].freeze # All are exclusive

    attr_reader(*VALUES)

    def to_h
      VALUES.map { |val| [val, public_send(val)] }.to_h
    end

    def initialize(executed: 0, not_executed: 0, not_executable: 0, ignored: 0)
      @executed = executed
      @not_executed = not_executed
      @not_executable = not_executable
      @ignored = ignored
      freeze
    end

    def +(other)
      self.class.new(to_h.merge(other.to_h) { |k, a, b| a + b })
    end

    def total
      to_h.values.inject(:+)
    end

    def with(**values)
      self.class.new(to_h.merge(values))
    end
  end

  class Analyser::Stats < Analyser::StatsBase
    DECIMALS = 2
    memoize :percent

    def percent
      Analyser::StatsBase.new(to_h.transform_values { |v| (100 * v).fdiv(total).round(DECIMALS) })
    end
  end
end
