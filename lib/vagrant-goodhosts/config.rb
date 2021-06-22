require "vagrant"

module VagrantPlugins
  module GoodHosts
    class Config < Vagrant.plugin("2", :config)
        attr_accessor :aliases
        attr_accessor :id
        attr_accessor :remove_on_suspend
        attr_accessor :disable_clean
        
        def initialize
            @remove_on_suspend = true
            @disable_clean = true
        end
    end
  end
end
