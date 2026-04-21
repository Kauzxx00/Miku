module Interactions
  class Base
    class << self
      attr_accessor :author_only,
                    :interaction_name

      def inherited(subclass)
        InteractionRouter.register(subclass)
      end

      def name(value)
        @interaction_name = value
      end

      def authorOnly?(value = true, char = ":")
        @author_only = [value, char]
      end
    end

    def initialize(client)
      @client = client
    end

    def run(_interaction)
      raise NotImplementedError
    end
  end
end

class InteractionRouter
  @handlers = []

  class << self
    attr_reader :handlers

    def register(handler)
      @handlers << handler
    end

    def load_handlers(path, client)
      Dir.glob("#{path}/**/*.rb").each do |file|
        require File.expand_path(file)
      end

      @instances = @handlers.map { |h| h.new(client) }
    end

    def run(interaction)
      return unless @instances

      @instances.each do |handler|
        begin
          custom_id = interaction.custom_id.split(handler.class.author_only[1])
          next unless handler.class.interaction_name.to_s == custom_id[0]
          if handler.class.author_only[0]
            next unless interaction.user.id.to_s == custom_id[1]
          end

          handler.run(interaction)
        rescue => e
          Rubord::Logger.error(
            "Erro em #{handler.class}: #{e.full_message}"
          )
        end
      end
    end
  end
end