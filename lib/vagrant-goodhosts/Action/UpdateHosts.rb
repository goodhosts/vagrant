# Run when is adding hosts
module VagrantPlugins
  module GoodHosts
    module Action
      # Update hosts
      class UpdateHosts < BaseAction
        def run(_env)
          addHostEntries()
        end
      end
    end
  end
end
