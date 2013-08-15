
module YARD
  module CodeObjects

    class ClassObject
      # Find all methods of a given scope
      #
      # @param [Symbol] scope     :constructor, :class, or :instance
      #
      # @return [Array<MethodObject>]
      def methods_by_scope(scope)
        meths.sort.find_all do |meth|
          if meth.constructor?
            if scope == :constructor then
              true
            else
              false
            end
          else
            meth.scope == scope
          end
        end
      end
    end

    class MethodObject
      # Comparator which sorts constructors first and then all other methods
      # by name
      def <=>(b)
        a = self
        if a.constructor? and b.constructor? then
          0
        elsif a.constructor? or b.constructor? then
          a.constructor? ? -1 : 1
        else
          a.name.to_s <=> b.name.to_s
        end
      end # <=>
    end

  end
end

