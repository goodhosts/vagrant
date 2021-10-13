# Run when is adding hosts
module VagrantPlugins
  module GoodHosts
    module Action
      # Update hosts
      class UpdateHosts < BaseAction
        def run(_env)
          add_host_entries()
        end
      end
    end
  end
end
