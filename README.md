# Vagrant::Goodhosts

This plugin adds an entry to your /etc/hosts file on the host system using [GoodHosts](https://github.com/goodhosts/cli). This plugin is based on [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) to be compatible with the same config parameters.

On **up**, **resume** and **reload** commands, it tries to add the information, if it does not already exist in your hosts file. If it needs to be added, you will be asked for an administrator password, since it uses sudo to edit the file.

On **halt**, **destroy**, and **suspend**, those entries will be removed again.
By setting the `config.goodhosts.remove_on_suspend  = false`, **suspend** and **halt** will not remove them. 


## Installation

    $ vagrant plugin install vagrant-goodhosts

Uninstall it with:

    $ vagrant plugin uninstall vagrant-goodhosts

Update the plugin with:

    $ vagrant plugin update vagrant-goodhosts

## Usage

You currently only need the `hostname` and a `:private_network` network with a fixed IP address.

    config.vm.network :private_network, ip: "192.168.3.10"
    config.vm.hostname = "www.testing.de"
    config.goodhosts.aliases = ["alias.testing.de", "alias2.somedomain.com"]

This IP address and the hostname will be used for the entry in the `/etc/hosts` file.

### Multiple private network adapters

If you have multiple network adapters i.e.:

    config.vm.network :private_network, ip: "10.0.0.1"
    config.vm.network :private_network, ip: "10.0.0.2"

you can specify which hostnames are bound to which IP by passing a hash mapping the IP of the network to an array of hostnames to create, e.g.:

    config.goodhosts.aliases = {
        '10.0.0.1' => ['foo.com', 'bar.com'],
        '10.0.0.2' => ['baz.com', 'bat.com']
    }

This will produce `/etc/hosts` entries like so:

    10.0.0.1 foo.com
    10.0.0.1 bar.com
    10.0.0.2 baz.com
    10.0.0.2 bat.com
        
### Keeping Host Entries After Suspend/Halt

To keep your /etc/hosts file unchanged simply add the line below to your `VagrantFile`:

    config.goodhosts.remove_on_suspend = false
    
This disables vagrant-goodhosts from running on **suspend** and **halt**.
        

## Suppressing prompts for elevating privileges

These prompts exist to prevent anything that is being run by the user from inadvertently updating the hosts file. 
If you understand the risks that go with supressing them, here's how to do it.

### Linux/OS X: Passwordless sudo

To allow vagrant to automatically update the hosts file without asking for a sudo password, add one of the following snippets to a new sudoers file include, i.e. `sudo visudo -f /etc/sudoers.d/vagrant_goodhosts`.

For Ubuntu and most Linux environments:

    # Allow passwordless startup of Vagrant with vagrant-goodhosts.
    Cmnd_Alias VAGRANT_HOSTS_ADD = /bin/sh -c echo "*" >> /etc/hosts
    Cmnd_Alias VAGRANT_HOSTS_REMOVE = /bin/sed -i -e /*/ d /etc/hosts
    %sudo ALL=(root) NOPASSWD: VAGRANT_HOSTS_ADD, VAGRANT_HOSTS_REMOVE

For MacOS:

    # Allow passwordless startup of Vagrant with vagrant-goodhosts.
    Cmnd_Alias VAGRANT_HOSTS_ADD = /bin/sh -c echo "*" >> /etc/hosts
    Cmnd_Alias VAGRANT_HOSTS_REMOVE = /usr/bin/sed -i -e /*/ d /etc/hosts
    %admin ALL=(root) NOPASSWD: VAGRANT_HOSTS_ADD, VAGRANT_HOSTS_REMOVE
    
- If vagrant still asks for a password on commands that trigger the `VAGRANT_HOSTS_ADD` alias above (like **up**), you might need to wrap the echo statement in quotes, i.e. `Cmnd_Alias VAGRANT_HOSTS_ADD = /bin/sh -c 'echo "*" >> /etc/hosts'`. This seems to be a problem with older versions of Linux and MacOS.
- If vagrant still asks for a password on commands that trigger the `VAGRANT_HOSTS_REMOVE` alias above (like
**halt** or **suspend**), this might indicate that the location of **sed** in the `VAGRANT_HOSTS_REMOVE` alias is
pointing to the wrong location. The solution is to find the location of **sed** (ex. `which sed`) and
replace that location in the `VAGRANT_HOSTS_REMOVE` alias.
    
### Windows: UAC Prompt

You can use `cacls` or `icacls` to grant your user account permanent write permission to the system's hosts file. 
You have to open an elevated command prompt; hold `❖ Win` and press `X`, then choose "Command Prompt (Admin)"

    cacls %SYSTEMROOT%\system32\drivers\etc\hosts /E /G %USERNAME%:W 

## Installing development version

If you would like to install vagrant-goodhosts on the development version perform the following:

```
git clone https://github.com/mte90/vagrant-goodhosts
cd vagrant-goodhosts
git checkout develop
./package.sh
vagrant plugin install vagrant-goodhosts-*.gem
```
