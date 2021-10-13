# Root file of the plugin
require "vagrant-goodhosts/version"
require "vagrant-goodhosts/plugin"

#Extend Vagrant Plugins
module VagrantPlugins
  # Load our plugin
  module GoodHosts
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
