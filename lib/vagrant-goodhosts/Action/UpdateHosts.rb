module VagrantPlugins
  module GoodHosts
    module Action
      class UpdateHosts < BaseAction

        def run(env)
          addHostEntries()
        end

      end
    end
  end
end
