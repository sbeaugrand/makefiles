# ---------------------------------------------------------------------------- #
## \file Vagrantfile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
Vagrant.configure("2") do |config|
  config.trigger.before [:up, :destroy] do |trigger|
    trigger.run = {inline: "bash -c 'lsmod | grep -q tun || sudo modprobe tun'"}
  end
  config.vm.provider :libvirt do |libvirt|
    libvirt.storage_pool_path = "/data/libvirt"
  end
  config.vm.synced_folder "./", "/vagrant", type: "sshfs"
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
  end
end
