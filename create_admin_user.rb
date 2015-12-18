#!/usr/bin/env ruby

require "json"

admin_user_file = File.expand_path("../admin_user.json",__FILE__)
s3_cmd_cfg = File.expand_path("../s3cmd.cfg",__FILE__)

# Does an admin user already exist?
if File.exists?(admin_user_file)
  puts "Admin user file exists. Remove file to run this script."
  exit(1)
end

# Try creating a user
json = `curl -H "Content-type: application/json" -XPOST http://192.168.111.11:8000/riak-cs/user -d '{"email":"admin@scpr.org","name":"admin_user"}'`

if $?.to_i != 0
  puts "Curl may not have been successful: #{json}"
  exit(1)
end

obj = JSON.parse json

if !obj['key_id'] || !obj['key_secret']
  puts "Parsed object does not have key and secret: #{obj}"
  exit(1)
end

# write admin_user.json
File.open(admin_user_file,"w") do |f|
  f.write json
end

# write s3cmd.cfg
File.open(s3_cmd_cfg,"w") do |f|
  f.write <<EOF
[default]
access_key = #{obj['key_id']}
secret_key = #{obj['key_secret']}
host_base = s3.i.scprdev.org
host_bucket = %(bucket)s.s3.i.scprdev.org

proxy_host = 192.168.111.14
proxy_port = 80
use_https = False
EOF
end