require 'open3'

module VagrantPlugins
  module GoodHosts
    module GoodHosts

      def getIps
        ips = []

        if ip = getAwsPublicIp
          ips.push(ip)
        elsif ip = getGooglePublicIp
          ips.push(ip)
        else
            @machine.config.vm.networks.each do |network|
              key, options = network[0], network[1]
              ip = options[:ip] if (key == :private_network || key == :public_network) && options[:goodhosts] != "skip"
              ips.push(ip) if ip
              if options[:goodhosts] == 'skip'
                @ui.info '[vagrant-goodhosts] Skipping adding host entries (config.vm.network goodhosts: "skip" is set)'
            end
          end
        end
      end

      # Get a hash of hostnames indexed by ip, e.g. { 'ip1': ['host1'], 'ip2': ['host2', 'host3'] }
      def getHostnames(ips)
        hostnames = Hash.new { |h, k| h[k] = [] }

        case @machine.config.goodhosts.aliases
        when Array
          # simple list of aliases to link to all ips
          ips.each do |ip|
            hostnames[ip] += @machine.config.goodhosts.aliases
          end
        when Hash
          # complex definition of aliases for various ips
          @machine.config.goodhosts.aliases.each do |ip, hosts|
            hostnames[ip] += Array(hosts)
          end
        end

        # handle default hostname(s) if not already specified in the aliases
        Array(@machine.config.vm.hostname).each do |host|
          if hostnames.none? { |k, v| v.include?(host) }
            ips.each do |ip|
              hostnames[ip].unshift host
            end
          end
        end

        return hostnames
      end

      def addHostEntries
        ips = getIps
        hostnames = getHostnames(ips)
        entries = []
        ips.each do |ip|
          hostnames[ip].each do |hostname|
              system("./cli", "a", ip, hostname)
              entries.push(hostEntry)
          end
        end
      end

      def removeHostEntries
        ips = getIps
        hostnames = getHostnames(ips)
        entries = []
        ips.each do |ip|
          hostnames[ip].each do |hostname|
              system("./cli", "r", ip, hostname)
              entries.push(hostEntry)
          end
        end
      end

    end
  end
end 
