require_relative "../GoodHosts"
module VagrantPlugins
  module GoodHosts
    module Action
      class UpdateHosts
        include GoodHosts

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
          @first = false
        end

        def call(env)
          unless @first
            @first = true
            @ui.info "[vagrant-goodhosts] Checking for host entries"
            addHostEntries()
          end
          @app.call(env)
        end

      end
    end
  end
end
