module VagrantPlugins
  module GoodHosts
    module Action
      class BaseAction
        include GoodHosts

        # Vagrant 2.2.14 has changed the hooks execution policy so they
        # started to be triggered more than once (a lot actually) which
        # is non-performant and floody. With this static property, we
        # control the executions and allowing just one.
        #
        # - https://github.com/hashicorp/vagrant/issues/12070#issuecomment-732271918
        # - https://github.com/hashicorp/vagrant/compare/v2.2.13..v2.2.14#diff-4d1af7c67af870f20d303c3c43634084bab8acc101055b2e53ddc0d07f6f64dcL176-L180
        # - https://github.com/goodhosts/vagrant/issues/25
        @@completed = {}

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          if not @@completed.key?(self.class.name)
            run(env)
            @@completed[self.class.name] = true
          end

          @app.call(env)
        end

        def run(env)
          raise NotImplementedError.new("Must be implemented!")
        end

      end
    end
  end
end
