module VagrantPlugins
  module GoodHosts
    module Action
      class RemoveHosts
        include GoodHosts

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          machine_action = env[:machine_action]
          if machine_action != :destroy || !@machine.id
            if machine_action != :suspend || false != @machine.config.goodhosts.remove_on_suspend
              @first ||= false
              unless @first
                @first = true
                if machine_action != :halt || false != @machine.config.goodhosts.remove_on_suspend
                  @ui.info "[vagrant-goodhosts] Removing hosts"
                  removeHostEntries
                else
                  @ui.info "[vagrant-goodhosts] Removing hosts on suspend disabled"
                end
              end
            end
          end
          @app.call(env)
        end

      end
    end
  end
end
