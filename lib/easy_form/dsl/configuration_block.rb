module EasyForm
  module DSL
    class ConfigurationBlock
      def initialize(&block)
        @atts = {}
        instance_eval(&block)
      end

      def method_missing(method, *args, **kwargs, &block)
        @atts[method] = if block && args.empty?
                          block
                        elsif kwargs.any?
                          kwargs
                        elsif args.size > 1
                          args
                        else
                          args.first
                        end
      end

      def respond_to_missing?(_method, _include_private = false)
        true
      end

      def to_h
        @atts
      end
    end
  end
end
