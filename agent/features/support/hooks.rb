
require 'fileutils'

Before do
    FileUtils.rm_rf("/tmp/devops/test") if File.exists? "/tmp/devops/test"
end

def catch_io(post, &block)
    original = eval("$std" + post)
    fake     = StringIO.new
    eval("$std#{post} = fake")
    begin
        yield
    ensure
        eval("$std#{post} = original")
    end
    fake.string
end

Before("@stdout") do
    REAL_STDOUT = $stdout if not Object.constants.include? "REAL_STDOUT"
    @stdout = StringIO.new
    eval("$stdout = @stdout")
end

Before("@stderr") do
    @stderr = StringIO.new
    eval("$stderr = @stderr")
end
