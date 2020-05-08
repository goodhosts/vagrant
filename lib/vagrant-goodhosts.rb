require "vagrant-goodhosts/version"
require "vagrant-goodhosts/plugin"

module VagrantPlugins
  module GoodHosts
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end

