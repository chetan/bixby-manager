
namespace :stark do
  task :view do

    state_dir = File.join(::Rails.root, "app/assets/javascripts/states")
    states = Dir.glob(File.join(state_dir, "*")).reject{ |d| d =~ /\..*$/ }.map{ |d| File.basename(d) }

    puts "Select state:"
    puts states
    STDOUT.write "> "
    state = STDIN.gets.strip

    STDOUT.write "view class name (in CamelCase): "
    view = STDIN.gets.strip
    tpl = view.underscore

    view_file = File.join(state_dir, state, "views", view.underscore + ".js.coffee")
    puts "creating #{view_file}"
    File.open(view_file, 'w') do |f|
      f.puts <<-EOF
namespace "Bixby.view", (exports, top) ->

  class exports.#{view} extends Stark.View
    el: "div#content"
    template: "#{state}/#{view.underscore}"

    events: {}
EOF
    end

    tpl_file = File.join(state_dir, state, "templates", view.underscore + ".jst.str")
    puts "creating #{tpl_file}"
    FileUtils.touch(File.join(state_dir, state, "templates", view.underscore + ".jst.str"))

  end
end
