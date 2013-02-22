require 'zeus/rails'

class CustomPlan < Zeus::Rails

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

  def test
    bootstrap_tests()
    super # runs the tests
  end

end

Zeus.plan = CustomPlan.new
