module Heroes
  module SharedKernel
    module Resources
      Type = [ :GOLD, :WOOD, :ORE, :MERCURY, :SULFUR, :CRYSTAL, :GEMS ]

      Amount = Data.define(:raw) do
        def self.of(raw)
          raise ArgumentError, "Amount cannot be negative" if raw < 0

          new(raw)
        end

        def self.zero
          new(0)
        end

        def <=>(other)
          raw <=> other.raw
        end

        def +(other)
          Amount.new(raw + other.raw)
        end

        def -(other)
          Amount.new(raw - other.raw)
        end
      end

      Cost = Data.define(:resources) do
        def self.resources(*resources)
          resource_map = resources.to_h { |type, amount| [ type, Amount.new(amount) ] }
          new(resource_map)
        end

        def *(multiplier)
          resource_map = resources.transform_values { |amount| Amount.new(amount.raw * multiplier) }
          self.class.new(resource_map)
        end

        def map_resources(&block)
          resources.transform_values { |amount| block.call(amount) }
        end
      end
    end
  end
end
