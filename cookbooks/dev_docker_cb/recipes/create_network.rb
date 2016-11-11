# recipe create_network
# cookbook dev_docker_cb
# purpose create dedicated docker networks

# Manage dependencies
require 'docker'

# Local Variables
server_net = "lcl-net-server"
app_net = "lcl-net-app"
db_net = "lcl-net-db"

# create server network
docker_network "#{server_net}" do
    subnet '172.20.0.0/16'
    gateway '172.20.0.1/16'
    action :create
end

# create app network
docker_network "#{app_net}" do
    subnet '172.21.0.0/16'
    gateway '172.21.0.1/16'
    action :create
end

# create db network
docker_network "#{db_net}" do
    subnet '172.22.0.0/16'
    gateway '172.22.0.1/16'
    action :create
end
