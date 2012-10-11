
module Bixby

  # Add before/after and named hooks (callbacks/events) to any class
  #
  # @example
  #
  #   class Foo
  #     extend Bixby::Hooks
  #     def hello(name)
  #       puts "(orig) hello #{name}"
  #     end
  #   end
  #
  #   # standard call, no hooks
  #   Foo.new.hello("joe")
  #
  #   # add before & after hooks
  #   Foo.add_before_hook(:hello) do |name|
  #     puts "(before) yo #{name}"
  #   end
  #
  #   Foo.add_before_hook(:hello) do |name|
  #     puts "(before) hulloooo #{name}"
  #   end
  #
  #   Foo.add_after_hook(:hello) do |name|
  #     puts "(after) sup #{name}"
  #   end
  #
  #   Foo.new.hello("joe")
  #
  #   # outputs:
  #   #
  #   # (orig) hello joe
  #   # (before) yo joe
  #   # (before) hulloooo joe
  #   # (orig) hello joe
  #   # (after) sup joe
  #
  module Hooks

    # Add a named callback method. Either a Proc or Block must be given.
    # Named hooks must be triggered manually.
    #
    # @param [Symbol] name      Name of the hook
    # @param [Proc] proc        Proc to execute (optional)
    # @param [Block] block      Block to execute (optional)
    def add_hook(name, proc=nil, &block)
      if not hooks.include? name then
        hooks[name] = []
      end
      if proc then
        hooks[name] << proc
      elsif block_given? then
        hooks[name] << block
      end
    end
    alias_method :add_callback, :add_hook

    # Add a hook to run before the given method. Either a Proc or Block must be
    # given.
    #
    # @param [Symbol] method    Name of the method to hook
    # @param [Proc] proc        Proc to execute (optional)
    # @param [Block] block      Block to execute (optional)
    def add_before_hook(method, proc=nil, &block)
      return if not instance_methods.include? :method
      if not before_hooks.include? method then
        before_hooks[method] = []
      end
      hook = proc || block
      before_hooks[method] << hook
      add_around_hooks(method)
    end

    # Add a hook to run after the given method. Either a Proc or Block must be
    # given.
    #
    # @param [Symbol] method    Name of the method to hook
    # @param [Proc] proc        Proc to execute (optional)
    # @param [Block] block      Block to execute (optional)
    def add_after_hook(method, proc=nil, &block)
      return if not instance_methods.include? :method
      if not after_hooks.include? method then
        after_hooks[method] = []
      end
      hook = proc || block
      after_hooks[method] << hook
      add_around_hooks(method)
    end

    # Get the list of registered hooks
    #
    # @return [Hash] name => Array<Proc>
    def hooks
      @hooks ||= {}
    end

    # Get the list of registered after hooks
    #
    # @return [Hash] name => Array<Proc>
    def before_hooks
      @before_hooks ||= {}
    end

    # Get the list of registered after hooks
    #
    # @return [Hash] name => Array<Proc>
    def after_hooks
      @after_hooks ||= {}
    end

    # Execute the given hook. Does not return any result nor catch any errors.
    #
    # @param [Symbol] name      Name of the hook to exeute
    # @param [*args] args       List of arguments to pass to hooks
    def run_hook(name, *args)
      return if not hooks.include? name
      hooks[name].each do |h|
        h.call(*args)
      end
    end
    alias_method :run_hooks, :run_hook



    private

    # Setup before/after hook infrastructure
    #
    # @param [Symbol] method    Name of the method to hook
    def add_around_hooks(method)
      old_method = "#{method}_without_hooks"
      return if instance_methods.include? old_method.to_sym

      alias_method old_method, method
      define_method(method) do |*args|
        self.class.before_hooks[method].each do |hook|
          hook.call(*args)
        end
        send(old_method, *args)
        self.class.after_hooks[method].each do |hook|
          hook.call(*args)
        end
      end
    end

  end
end
