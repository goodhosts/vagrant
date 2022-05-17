# The core of the plugin
require "rbconfig"
require "open3"
require "resolv"
require "os"

module VagrantPlugins
  module GoodHosts
    # Plugin module
    module GoodHosts
      def get_ips
        ips = []

        if @machine.config.vm.networks.empty?
          @ui.error("[vagrant-goodhosts] No networks are available yet for this virtual machine to add IP/hosts for")
          return ips
        end

        @machine.config.vm.networks.each do |network|
          key, options = network[0], network[1]
          if options[:goodhosts] == "skip"
            @ui.info '[vagrant-goodhosts] Skipped adding host entries (config.vm.network goodhosts: "skip" is set)'
          end
          ip = options[:ip] if (key == :private_network || key == :public_network) && options[:goodhosts] != "skip"
          ips.push(ip) if ip

          @machine.config.vm.provider :hyperv do
            timeout = @machine.provider_config.ip_address_timeout
            @ui.output("[vagrant-goodhosts] Waiting for the guest machine to report its IP address ( this might take some time, have patience )...")
            @ui.detail("Timeout: #{timeout} seconds")

            options = {
              vmm_server_address: @machine.provider_config.vmm_server_address,
              proxy_server_address: @machine.provider_config.proxy_server_address,
              timeout: timeout,
              machine: @machine
            }
            network = @machine.provider.driver.read_guest_ip(options)
            if network["ip"]
              ips.push(network["ip"]) unless ips.include? network["ip"]
            end
          end
        end
        return ips
      end

      def get_os_binary
        if OS.windows?
          return 'cli.exe'
        elsif OS.mac?
          if Etc.uname[:version].include? 'ARM64'
            return 'cli_arm64_osx'
          else
            return 'cli_amd64_osx'
          end
        elsif OS.linux?
          return 'cli'
        else
          raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
        end
      end

      def get_cli
        binary = get_os_binary
        path = format('%s%s', File.expand_path(File.dirname(File.dirname(__FILE__))), "/vagrant-goodhosts/bundle/")
        path = "#{path}#{binary}"

        return path
      end

      # Get a hash of hostnames indexed by ip, e.g. { 'ip1': ['host1'], 'ip2': ['host2', 'host3'] }
      def get_hostnames(ips)
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

        return hostnames
      end

      def disable_clean(ip_address)
        unless ip_address.nil?
          return @machine.config.goodhosts.disable_clean
        end

        return true
      end

      def check_hostnames_to_add(ip_address, hostnames)
        hostnames_to_add = Array.new
        hostnames = hostnames.split
        # check which hostnames actually need adding
        hostnames.each do |hostname|
          begin
            address = Resolv.getaddress(hostname)
            if address != ip_address
              hostnames_to_add.append(hostname)
            end
          rescue StandardError => _e
            hostnames_to_add.append(hostname)
          end
        rescue StandardError => _e
          hostnames_to_add.append(hostname)
        end
        return hostnames_to_add.join(' ')
      end

      def add_goodhost_entries(ip_address, hostnames)
        cli = get_cli
        if cli.include? ".exe"
          clean = get_clean_parameter_by_system(ip_address, true)
          command = "Start-Process '#{cli}' -ArgumentList \"add\",#{clean}\"#{ip_address}\",\"#{hostnames}\" -Verb RunAs"
          stdin, stdout, stderr, wait_thr = Open3.popen3("powershell", "-Command", command)
        else
          clean = get_clean_parameter_by_system(ip_address, false)
          command = "sudo '#{cli}' add #{clean} #{ip_address} #{hostnames}"
          stdin, stdout, stderr, wait_thr = Open3.popen3(command)
        end
        return stdin, stdout, stderr, wait_thr, command
      end

      def add_host_entries
        error = false
        error_text = ''
        command = ''
        hostnames_by_ips = generate_hostnames_by_ips

        return if hostnames_by_ips.none?

        @ui.info "[vagrant-goodhosts] Checking for host entries"

        hostnames_by_ips.each do |ip_address, hostnames|
          if ip_address.nil?
            @ui.error "[vagrant-goodhosts] Error adding some hosts, no IP was provided for the following hostnames: #{hostnames}"
            next
          end

          # filter out the hosts we've already added
          hosts_to_add = check_hostnames_to_add(ip_address, hostnames)
          next if hosts_to_add.empty?

          _stdin, _stdout, stderr, wait_thr, command = add_goodhost_entries(ip_address, hosts_to_add)
          unless wait_thr.value.success?
            error = true
            error_text = stderr.read.strip
          end
        end
        print_readme(error, error_text, command)
      end

      def remove_goodhost_entries(ip_address, hostnames)
        cli = get_cli
        if cli.include? ".exe"
          clean = get_clean_parameter_by_system(ip_address, true)
          command = "Start-Process '#{cli}' -ArgumentList \"remove\",#{clean}\"#{ip_address}\",\"#{hostnames}\" -Verb RunAs"
          stdin, stdout, stderr, wait_thr = Open3.popen3("powershell", "-Command", command)
        else
          clean = get_clean_parameter_by_system(ip_address, false)
          command = "sudo '#{cli}' remove #{clean} #{ip_address} #{hostnames}"
          stdin, stdout, stderr, wait_thr = Open3.popen3(command)
        end
        return stdin, stdout, stderr, wait_thr, command
      end

      def remove_host_entries
        error = false
        error_text = ''
        command = ''
        hostnames_by_ips = generate_hostnames_by_ips

        return if hostnames_by_ips.none?

        @ui.info "[vagrant-goodhosts] Removing hosts"

        hostnames_by_ips.each do |ip_address, hostnames|
          if ip_address.nil?
            @ui.error "[vagrant-goodhosts] Error adding some hosts, no IP was provided for the following hostnames: #{hostnames}"
            next
          end

          _stdin, _stdout, stderr, wait_thr, command = remove_goodhost_entries(ip_address, hostnames)
          unless wait_thr.value.success?
            error = true
            error_text = stderr.read.strip
          end
        end
        print_readme(error, error_text, command)
      end

      def get_clean_parameter_by_system(ip_address, is_win)
        clean = "--clean"
        if is_win
          clean = "\"--clean\","
        end

        if disable_clean(ip_address)
          clean = ''
        end
        return clean
      end

      def print_readme(error, error_text, command)
        unless error
          @ui.info "[vagrant-goodhosts] Finished processing"
          return false
        end

        cli = get_cli
        @ui.error "[vagrant-goodhosts] Issue executing goodhosts CLI: #{error_text}"
        @ui.error "[vagrant-goodhosts] Command: #{command}"
        @ui.error "[vagrant-goodhosts] Cli path: #{cli}"
        if cli.include? ".exe"
          @ui.error "[vagrant-goodhosts] Check the readme at https://github.com/goodhosts/vagrant#windows-uac-prompt"
          exit
        else
          @ui.error "[vagrant-goodhosts] Check the readme at https://github.com/goodhosts/vagrant#passwordless-sudo"
        end
      end

      def append_hostsnames_by_ips(hostnames_by_ips, hostnames, ip_address, ip_index)
        if hostnames[ip_index].count() > 0
          hostnames[ip_index].each do |hostname|
            unless ip_address.nil?
              @ui.info "[vagrant-goodhosts] - found entry for: #{ip_address} #{hostname}"
            end
          end
          hostnames_by_ips = { ip_address => hostnames[ip_index].join(" ") }
        end
        return hostnames_by_ips
      end

      def generate_hostnames_by_ips
        hostnames_by_ips = []
        ips = get_ips
        if ips.count() < 1
          @ui.error("[vagrant-goodhosts] No ip address found for this virtual machine")
          return hostnames_by_ips
        end
        hostnames = get_hostnames(ips)
        if ips.count() > 1
          ips.each do |ip|
            ip_address = ip
            hostnames_by_ips = append_hostsnames_by_ips(hostnames_by_ips, hostnames, ip_address, ip)
          end
        else
          ip_address = ips[0]
          hostnames_by_ips = append_hostsnames_by_ips(hostnames_by_ips, hostnames, ip_address, ip_address)
        end

        return hostnames_by_ips
      end
    end
  end
end
