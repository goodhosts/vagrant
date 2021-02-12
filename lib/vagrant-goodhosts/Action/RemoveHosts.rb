module VagrantPlugins
  module GoodHosts
    module Action
      class RemoveHosts < BaseAction

        def run(env)
          machine_action = env[:machine_action]
          if machine_action != :destroy || !@machine.id
            if machine_action != :suspend || false != @machine.config.goodhosts.remove_on_suspend
              if machine_action != :halt || false != @machine.config.goodhosts.remove_on_suspend
                @ui.info "[vagrant-goodhosts] Removing hosts"
                removeHostEntries
              else
                @ui.info "[vagrant-goodhosts] Removing hosts on suspend disabled"
              end
            end
          end
        end

      end
    end
  end
end
