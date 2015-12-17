require "chef/provisioning/vagrant_driver"

vagrant_box "precise64" do
  url "http://files.vagrantup.com/precise64.box"
end

with_driver "vagrant"

# -- consul -- #

consul_ip = "192.168.111.10"
haproxy_ip = "192.168.111.14"

machine "consul" do
  converge true
  run_list ["recipe[scpr-consul]"]

  machine_options(
    vagrant_options:{
      'vm.box' => "precise64",
    },
    vagrant_config:<<-EOS
      config.vm.network :private_network, ip:"#{consul_ip}"
    EOS
  )

  attributes({
    consul: {
      servers: [consul_ip],
      serve_ui: true,
      bootstrap_expect: 1,
      service_mode: 'cluster',
      advertise_interface: "eth1",
    }
  })
end

# -- riakcs servers -- #

3.times do |i|
  machine "riakcs00#{i}" do
    converge true
    run_list ["recipe[scpr-consul]","recipe[scpr-riakcs]"]

    ip = "192.168.111.#{11+i}"

    machine_options(
      vagrant_options:{
        'vm.box' => "precise64",
      },
      vagrant_config:<<-EOS
        config.vm.network :private_network, ip:"#{ip}"
        config.vm.provider "virtualbox" do |v|
          v.memory = 2048
        end
      EOS
    )

    attributes({
      scpr_riakcs: {
        root_host:    'riak.ewr',
        ip:           ip,
        stanchion_ip: haproxy_ip,
        admin_key:    "XPXWM5YXYMRUBYPLWVQK",
        admin_secret: "dN9KXDZxn9kh5pDrdVNF8X6-PXIKC11GDDwF9g==",
        anon_create:  false,
      },
      consul: {
        servers: [consul_ip],
        advertise_interface: "eth1",
      }
    })
  end
end

# -- HAProxy -- #

machine "haproxy" do
  converge true
  run_list ["recipe[scpr-consul]","recipe[scpr-riakcs::haproxy]"]

  machine_options(
    vagrant_options:{
      'vm.box' => "precise64",
    },
    vagrant_config:<<-EOS
      config.vm.network :private_network, ip:"#{haproxy_ip}"
    EOS
  )

  attributes({
    scpr_riakcs: {
      root_host: 'riak.ewr'
    },
    consul: {
      servers: [consul_ip],
      advertise_interface: "eth1",
    },
    scpr_consul_haproxy: {
      admin_interface: "eth1"
    }
  })
end
