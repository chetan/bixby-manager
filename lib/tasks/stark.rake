
class StarkViewTask
  class << self

    def create_view(partial=false)

      state_dir = File.join(::Rails.root, "app/assets/javascripts/states")
      states = Dir.glob(File.join(state_dir, "*")).reject{ |d| d =~ /\..*$/ }.map{ |d| File.basename(d) }

      puts "Select state:"
      puts states
      STDOUT.write "> "
      state = STDIN.gets.strip

      STDOUT.write "view class name (in CamelCase): "
      view = STDIN.gets.strip
      tpl = view.underscore

      file_base = (partial ? "_" : "") + view.underscore
      view_file = File.join(state_dir, state, "views", file_base + ".js.coffee")
      tpl_file = File.join(state_dir, state, "templates", file_base + ".jst.str")

      puts "creating #{view_file}"

      if partial
        clazz = "Partial"
        el = "className: \"#{view.underscore}\""
      else
        clazz = "View"
        el = 'el: "div#content"'
      end

      File.open(view_file, 'w') do |f|
        f.puts <<-EOF
  namespace "Bixby.view", (exports, top) ->

    class exports.#{view} extends Stark.#{clazz}
      #{el}
      template: "#{state}/#{file_base}"

      events: {}
  EOF
      end

      puts "creating #{tpl_file}"
      FileUtils.touch(tpl_file)
      end

  end
end

namespace :stark do
  desc "Create a new Stark View"
  task :view do
    StarkViewTask.create_view()
  end

  desc "Create a new Stark Partial View"
  task :partial do
    StarkViewTask.create_view(true)
  end
end
