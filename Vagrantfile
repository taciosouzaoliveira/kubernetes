Vagrant.configure("2") do |config|
config.vm.box = "generic/ubuntu2204"

# Disable automatic box update
config.vm.box_check_update = false

# Copy the setup script
config.vm.provision "file", source: "./k8s-setup.sh", destination: "/tmp/k8s-setup.sh"

# Execute setup script
config.vm.provision "shell", inline: "chmod +x /tmp/k8s-setup.sh && /tmp/k8s-setup.sh"

config.vm.provider :libvirt do |libvirt|
    libvirt.cpu_mode = "host-passthrough"
    libvirt.memory = 2048
    libvirt.cpus = 2
end

  # Master Node
  config.vm.define "k8s-master" do |master|
    master.vm.hostname = "k8s-master"
    master.vm.network "private_network", ip: "192.168.56.10"

    # Add hosts entries
    master.vm.provision "shell", inline: <<-SHELL
    echo "192.168.56.10 k8s-master" >> /etc/hosts
    echo "192.168.56.11 k8s-worker1" >> /etc/hosts
    echo "192.168.56.12 k8s-worker2" >> /etc/hosts
    SHELL
    
    master.vm.provider :libvirt do |libvirt|
      libvirt.memory = 4096
    end
  end

# Worker Nodes
(1..2).each do |i|
    config.vm.define "k8s-worker#{i}" do |worker|
    worker.vm.hostname = "k8s-worker#{i}"
    worker.vm.network "private_network", ip: "192.168.56.#{i + 10}"

    # Add hosts entries
    worker.vm.provision "shell", inline: <<-SHELL
        echo "192.168.56.10 k8s-master" >> /etc/hosts
        echo "192.168.56.11 k8s-worker1" >> /etc/hosts
        echo "192.168.56.12 k8s-worker2" >> /etc/hosts
    SHELL
    end
end
end
