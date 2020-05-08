require_relative "../HostsUpdater"
module VagrantPlugins
  module GoodHosts
    module Action
      class UpdateHosts
        include GoodHosts


        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          @ui.info "[vagrant-goodhosts] Checking for host entries"
          addHostEntries()
          @app.call(env)
        end

      end
    end
  end
end
