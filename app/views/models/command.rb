
module Bixby
  module ApiView
    class Command < ::ApiView::Base

      for_model ::Command
      attributes :id, :name, :desc, :location, :bundle, :command, :options

      def convert
        super
        self[:repo] = obj.repo.name

        manifest = obj.to_command_spec.manifest
        self[:help]     = manifest["help"]
        self[:help_url] = manifest["help_url"]

        self
      end

    end
  end
end
