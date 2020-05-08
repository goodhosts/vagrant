module VagrantPlugins
  module HostsUpdater
    class Command < Vagrant.plugin('2', :command)

      def execute
        puts "ran command"
      end
    end
  end
end
