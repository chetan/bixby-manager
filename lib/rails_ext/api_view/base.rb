
module ApiView

  class Base < ::Hash

    class << self

      # Attach to the given model
      #
      # @param [Class] model
      def for_model(model)
        @model = model
        ApiView.add_model(model, self)
      end

      def parent_attributes
        parent = self.superclass
        return [] if parent.name == "ApiView::Base"
        return parent.instance_variable_get(:@attributes)
      end

      # Include the given attributes in the output
      #
      # @param [Array<Symbol>] attrs
      #
      # Two special options are also allowed:
      #
      # attributes :except => :foobar
      # will include *all* attributes *except* `foobar`
      #
      # attributes :all
      # will include all of the objects attributes
      def attributes(*attrs)

        @attributes ||= []

        if attrs.last.kind_of? Hash then
          # handle the form
          # attributes :except => :foobar
          if attrs.last[:except] then
            e = attrs.last[:except]
            skip = (e.kind_of?(Array) ? e : [e]).map{ |s| s.to_s }
            attrs = @model.attribute_names.reject{ |s| skip.include?(s.to_s) }
          end

        elsif attrs.include? :all then
          # handle the form
          # attributes :all
          attrs = @model.attribute_names

        end

        @attributes = (@attributes + attrs).flatten
        parent_attributes.reverse.each do |a|
          @attributes.unshift(a) if not @attributes.include? a
        end

        # create a method which reads each attribute from the model object and
        # copies it into the hash, then returns the hash itself
        # e.g.,
        # def collect_attributes
        #   self.store(:foo, @object.foo)
        #   ...
        #   self
        # end
        code = ["def collect_attributes()"]
        @attributes.each do |a|
          code << "self.store(:#{a}, @object.#{a})"
        end
        code << "end"
        class_eval(code.join("\n"))

      end
      alias_method :attrs, :attributes

    end

    attr_reader :object
    alias_method :obj, :object

    def initialize(object)
      super(nil)
      @object = object
    end

    def collect_attributes
      # no-op by default
    end

    def convert
      collect_attributes()
      self
    end

    def render(obj, options=nil)
      Engine.convert(obj, options)
    end

  end

end
