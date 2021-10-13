# Run when is removing the hosts
module VagrantPlugins
  module GoodHosts
    module Action
      # Remove hosts
      class RemoveHosts < BaseAction
        def run(env)
          machine_action = env[:machine_action]

          return unless @machine.id
          return unless [:destroy, :halt, :suspend].include? machine_action

          if ([:halt, :suspend].include? machine_action) && (false == @machine.config.goodhosts.remove_on_suspend)
            @ui.info "[vagrant-goodhosts] Removing hosts on suspend disabled"
          else
            removeHostEntries
          end
        end
      end
    end
  end
end
