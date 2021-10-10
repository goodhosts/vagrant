module VagrantPlugins
  module GoodHosts
    module Action
      class UpdateHosts < BaseAction

        def run(env)
          @ui.info "[vagrant-goodhosts] Checking for host entries"
          addHostEntries()
        end

      end
    end
  end
end
