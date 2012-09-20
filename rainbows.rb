
worker_processes 4 # assuming four CPU cores
Rainbows! do
  use :Coolio
  worker_connections 100
  keepalive_timeout 60
  listen 3000
end
