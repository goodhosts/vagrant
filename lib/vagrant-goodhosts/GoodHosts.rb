require 'rbconfig'

module VagrantPlugins
  module GoodHosts
    module GoodHosts

      def getIps
        ips = []

            @machine.config.vm.networks.each do |network|
              key, options = network[0], network[1]
              ip = options[:ip] if (key == :private_network || key == :public_network) && options[:goodhosts] != "skip"
              ssh_info = nil
              i = 0
              @ui.info '[vagrant-goodhosts] Trying SSH host detection'
              while i < 4 do
                i += 1
                ssh_info = @machine.ssh_info
                break if ssh_info
                sleep 0.5
              end
              if ssh_info.nil?
                  ip = (ssh_info ? ssh_info[:host] : nil)
              end
              ips.push(ip) if ip
              if options[:goodhosts] == 'skip'
                @ui.info '[vagrant-goodhosts] Skipping adding host entries (config.vm.network goodhosts: "skip" is set)'
            end
        end
      end
      
      # https://stackoverflow.com/a/13586108/1902215
      def get_OS
        return os ||= (
        host_os = RbConfig::CONFIG['host_os']
        case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            :windows
        when /darwin|mac os/
            :macosx
        when /linux/
            :linux
        else
            raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
        end
        )
      end
      
      def get_cli
          os = get_OS
          path = File.expand_path(File.dirname(File.dirname(__FILE__))) + '/vagrant-goodhosts/bundle/cli/'
          if os == 'linux'
              path = path + 'cli'
          elseif os == 'macosc'
              path = path + 'cli.dmg'
          elseif os == 'windows'
              path = path + 'cli.exe'
          end
          
          return path
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
        ips.each do |ip|
          hostnames[ip].each do |hostname|
              ip_address = ip[1][:ip]
              if !ip_address.nil?
                @ui.info "[vagrant-goodhosts]   found entry for: #{ip_address} #{hostname}"
                system(get_cli, "a", ip_address, hostname)
              end
          end
        end
      end

      def removeHostEntries
        ips = getIps
        hostnames = getHostnames(ips)
        ips.each do |ip|
          hostnames[ip].each do |hostname|
              ip_address = ip[1][:ip]
              if !ip_address.nil?
                @ui.info "[vagrant-goodhosts]   remove entry for: #{ip_address} #{hostname}"
                system(get_cli, "r", ip_address, hostname)
              end
          end
        end
      end

    end
  end
end 
