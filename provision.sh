#!/bin/bash

berks vendor cookbooks/
chef-client -c ./client.rb -z ./provision.rb