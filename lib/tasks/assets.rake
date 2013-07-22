
begin
  require 'sprockets-font_compressor'
  require 'rake/hooks'

  before 'assets:precompile' do
    # remove all comments
    require 'uglifier'
    Uglifier::DEFAULTS[:output][:comments] = :none
  end

rescue LoadError => ex
end
