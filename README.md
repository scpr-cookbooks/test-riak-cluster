# test-riak-cluster

Spin up a test Riak CS cluster using our cookbooks, Chef Provisioning and Vagrant.

## Generate the Nodes

Use `provision.sh` to run Chef Provisioning, which will create five VMs: a
Consul server, three Riak / Riak CS nodes, and one HAproxy node.

## Join the Riak Cluster

Upon successful provisioning, each Riak instance will be running its own
single-node cluster.

Go to http://192.168.111.11:8098/admin#/cluster and add the following nodes:

* `riak@riakcs001.node.consul`
* `riak@riakcs002.node.consul`

## Create an Admin User

To create an admin user:

    ./create_admin_user.rb

Then rerun `provision.sh` to send the admin creds to the servers.


## Testing

Once the cluster is provisioned, you should be able to:

* Connect to the Consul server UI at http://192.168.111.10:8500 and see healthy
    services for s3 and s3-lb.
* You should find the HAproxy stats interface at http://192.168.111.14:1944,
    listing frontends and backends for `http`, `pb` and `stanchion`.
* HAproxy should show riakcs000 as the stanchion choice and all three nodes
    as backends for http and pb.
* Hitting http://192.168.111.14 should give you an XML-formatted Access Denied