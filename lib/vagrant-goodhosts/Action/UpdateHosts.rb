require_relative "../GoodHosts"
module VagrantPlugins
  module GoodHosts
    module Action
      class UpdateHosts
        include GoodHosts
        @@updated = false

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          machine_action = env[:machine_action]
          unless @@updated
            @@updated = true
            @ui.info "[vagrant-goodhosts] Checking for host entries"
            addHostEntries()
          end
          @app.call(env)
        end

      end
    end
  end
end
