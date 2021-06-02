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
          # Check whether the plugin has been executed for a particular
          # VM as it may happen that a single Vagrantfile defines multiple
          # machines and having a static flag will result in a plugin being
          # executed just once.
          # https://github.com/goodhosts/vagrant/issues/30
          @@completed[@machine.name] = [] unless @@completed.key?(@machine.name)
          unless @@completed[@machine.name].include? self.class.name
            run(env)
            @@completed[@machine.name] << self.class.name
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
