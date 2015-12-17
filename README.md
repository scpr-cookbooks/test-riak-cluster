# test-riak-cluster

Spin up a test Riak CS cluster using our cookbooks, Chef Provisioning and Vagrant.

## Testing

Once the cluster is provisioned, you should be able to:

* Connect to the Consul server UI at http://192.168.111.10:8500 and see healthy
    services for s3 and s3-lb.
* You should find the HAproxy stats interface at http://192.168.111.14:1944,
    listing frontends and backends for `http`, `pb` and `stanchion`.
* HAproxy should show riakcs000 as the stanchion choice and all three nodes
    as backends for http and pb.
* Hitting http://192.168.111.14 should give you an XML-formatted Access Denied