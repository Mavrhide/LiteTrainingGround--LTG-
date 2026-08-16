# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |v|
    v.gui = false
    v.memory = "1024"
    v.cpus = 1
  end

  WAZUH_MANAGER_IP = "10.0.40.10"

  def wazuh_agent_provision(agent_name)
    <<-SHELL
      set -e
      cd /root
      curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.7-1_amd64.deb
      WAZUH_MANAGER='#{WAZUH_MANAGER_IP}' WAZUH_AGENT_NAME='#{agent_name}' dpkg -i ./wazuh-agent.deb
      systemctl daemon-reload
      systemctl enable wazuh-agent
      systemctl start wazuh-agent
    SHELL
  end

  def route_to_soc_provision(gateway_ip)
    <<-SHELL
      ip route replace 10.0.40.0/24 via #{gateway_ip} dev eth1
    SHELL
  end

  # =====================================================
  # 0. ATTACKER PC — Kali Linux (10.0.0.100)
  # =====================================================
  config.vm.define "kali" do |kali|
    kali.vm.hostname = "attacker-kali"
    kali.vm.box = "kalilinux/rolling"

    kali.vm.network "private_network", ip: "10.0.0.100", virtualbox__intnet: "kali_net"

    kali.vm.provider "virtualbox" do |v|
      v.gui = true
      v.memory = "4096"
      v.cpus = 2
    end

    kali.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y kali-desktop-xfce lightdm virtualbox-guest-x11
      systemctl set-default graphical.target
      systemctl enable lightdm
    SHELL
  end

  # =====================================================
  # 1. CENTRAL FIREWALL ROUTER (10.0.0.1 + gateway на каждую зону)
  # =====================================================
  config.vm.define "router" do |router|
    router.vm.hostname = "central-fw-router"

    router.vm.network "private_network", ip: "10.0.0.1",    virtualbox__intnet: "kali_net"
    router.vm.network "private_network", ip: "10.0.10.254", virtualbox__intnet: "ecom_net"
    router.vm.network "private_network", ip: "10.0.20.254", virtualbox__intnet: "bank_net"
    router.vm.network "private_network", ip: "10.0.30.254", virtualbox__intnet: "hosp_net"
    router.vm.network "private_network", ip: "10.0.40.254", virtualbox__intnet: "soc_net"

    router.vm.provider "virtualbox" do |v|
      v.memory = "1024"
    end

    router.vm.provision "shell", name: "ip-forward", inline: <<-SHELL
      sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
      if ! grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf; then
        echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
      fi
      sysctl -p
    SHELL

    router.vm.provision "shell", name: "suricata", inline: <<-SHELL
      set -e
      export DEBIAN_FRONTEND=noninteractive
      add-apt-repository -y ppa:oisf/suricata-stable
      apt-get update
      apt-get install -y suricata
    SHELL

    router.vm.provision "shell", name: "firewall", inline: <<-SHELL
      set -e
      curl -sL -o /root/Iptables.sh https://raw.githubusercontent.com/Mavrhide/LiteTrainingGround--LTG-/refs/heads/main/scripts/Iptables.sh
      chmod +x /root/Iptables.sh
      bash /root/Iptables.sh
    SHELL
  end

  # =====================================================
  # 2. E-COMMERCE ZONE — 10.0.10.0/24 (Свитч: ecom_net)
  # =====================================================
  config.vm.define "ecom_waf" do |m|
    m.vm.hostname = "ecom-waf"
    m.vm.network "private_network", ip: "10.0.10.10", virtualbox__intnet: "ecom_net"
    m.vm.provision "shell", inline: route_to_soc_provision("10.0.10.254")
    m.vm.provision "shell", inline: wazuh_agent_provision("ecom-waf")
  end

  config.vm.define "ecom_db" do |m|
    m.vm.hostname = "ecom-db-server"
    m.vm.network "private_network", ip: "10.0.10.20", virtualbox__intnet: "ecom_net"
    m.vm.provision "shell", inline: route_to_soc_provision("10.0.10.254")
    m.vm.provision "shell", inline: wazuh_agent_provision("ecom-db-server")
  end

  config.vm.define "ecom_web" do |m|
    m.vm.hostname = "ecom-web-server"
    m.vm.network "private_network", ip: "10.0.10.30", virtualbox__intnet: "ecom_net"
    m.vm.provision "shell", inline: route_to_soc_provision("10.0.10.254")
    m.vm.provision "shell", inline: wazuh_agent_provision("ecom-web-server")
  end

  # =====================================================
  # 3. BANK ZONE — 10.0.20.0/24 (Свитч: bank_net)
  # =====================================================
  config.vm.define "bank_ips" do |m|
    m.vm.hostname = "bank-ips"
    m.vm.network "private_network", ip: "10.0.20.10", virtualbox__intnet: "bank_net"
    m.vm.provision "shell", inline: route_to_soc_provision("10.0.20.254")
    m.vm.provision "shell", inline: wazuh_agent_provision("bank-ips")
  end

  config.vm.define "bank_db" do |m|
    m.vm.hostname = "bank-db-server"
    m.vm.network "private_network", ip: "10.0.20.20", virtualbox__intnet: "bank_net"
    m.vm.provision "shell", inline: route_to_soc_provision("10.0.20.254")
    m.vm.provision "shell", inline: wazuh_agent_provision("bank-db-server")
  end

  config.vm.define "bank_app" do |m|
    m.vm.hostname = "bank-app-server"
    m.vm.network "private_network", ip: "10.0.20.30", virtualbox__intnet: "bank_net"
    m.vm.provision "shell", inline: route_to_soc_provision("10.0.20.254")
    m.vm.provision "shell", inline: wazuh_agent_provision("bank-app-server")
  end

  # =====================================================
  # 4. HOSPITAL ZONE — 10.0.30.0/24 (Свитч: hosp_net)
  # =====================================================
  config.vm.define "hosp_emr" do |m|
    m.vm.hostname = "hospital-emr-server"
    m.vm.network "private_network", ip: "10.0.30.10", virtualbox__intnet: "hosp_net"
    m.vm.provision "shell", inline: route_to_soc_provision("10.0.30.254")
    m.vm.provision "shell", inline: wazuh_agent_provision("hospital-emr-server")
  end

  config.vm.define "hosp_db" do |m|
    m.vm.hostname = "hospital-db-server"
    m.vm.network "private_network", ip: "10.0.30.20", virtualbox__intnet: "hosp_net"
    m.vm.provision "shell", inline: route_to_soc_provision("10.0.30.254")
    m.vm.provision "shell", inline: wazuh_agent_provision("hospital-db-server")
  end

  config.vm.define "hosp_file" do |m|
    m.vm.hostname = "hospital-file-server"
    m.vm.network "private_network", ip: "10.0.30.30", virtualbox__intnet: "hosp_net"
    m.vm.provision "shell", inline: route_to_soc_provision("10.0.30.254")
    m.vm.provision "shell", inline: wazuh_agent_provision("hospital-file-server")
  end

  # =====================================================
  # 5. SOC ZONE — 10.0.40.0/24 (Свитч: soc_net)
  # =====================================================
  WAZUH_DASHBOARD_PASSWORD = "LiteTrainingGround2026*"

  config.vm.define "soc_siem" do |m|
    m.vm.hostname = "soc-siem"
    m.vm.network "private_network", ip: "10.0.40.10", virtualbox__intnet: "soc_net"
    m.vm.provider "virtualbox" do |v|
      v.memory = "2048"
    end

    m.vm.provision "shell", name: "routes", inline: <<-SHELL
      ip route replace 10.0.10.0/24 via 10.0.40.254 dev eth1
      ip route replace 10.0.20.0/24 via 10.0.40.254 dev eth1
      ip route replace 10.0.30.0/24 via 10.0.40.254 dev eth1
    SHELL

    m.vm.provision "shell", name: "wazuh-install", inline: <<-SHELL
      set -e
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y curl
      cd /root
      if [ ! -f wazuh-install.sh ]; then
        curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
      fi
      if ! systemctl is-active --quiet wazuh-dashboard 2>/dev/null; then
        bash wazuh-install.sh -a -i
      fi
    SHELL

    m.vm.provision "shell", name: "wazuh-password", inline: <<-SHELL
      set -e
      cd /root
      curl -sL -o reset-wazuh-password.sh https://raw.githubusercontent.com/Mavrhide/LiteTrainingGround--LTG-/refs/heads/main/scripts/reset-wazuh-password.sh
      chmod +x reset-wazuh-password.sh
      bash reset-wazuh-password.sh '#{WAZUH_DASHBOARD_PASSWORD}'
    SHELL
  end

  config.vm.define "soc_log" do |m|
    m.vm.hostname = "soc-log-server"
    m.vm.network "private_network", ip: "10.0.40.20", virtualbox__intnet: "soc_net"
  end

  config.vm.define "soc_intel" do |m|
    m.vm.hostname = "soc-threat-intel"
    m.vm.network "private_network", ip: "10.0.40.30", virtualbox__intnet: "soc_net"
  end

end
