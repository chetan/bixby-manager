
begin
  require 'rake/hooks'

  before 'assets:precompile' do
    # remove all comments
    require 'uglifier'
    Uglifier::DEFAULTS[:output][:comments] = :none
  end

  before 'assets:precompile:all' do
    # remove all comments
    require 'uglifier'
    Uglifier::DEFAULTS[:output][:comments] = :none
  end

rescue LoadError => ex
end
