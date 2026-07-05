fx_version "cerulean"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
lua54 "yes"
author "Gaming Multiverse"
version "1.0.2"

client_scripts {
  "client/*.lua"
}

server_scripts {
  "@oxmysql/lib/MySQL.lua",
  "server/*.lua"
}

shared_scripts {
  "@jo_libs/init.lua",
  "@ox_lib/init.lua",
}

jo_libs {
  'dataview',
}

files {
  "shared/*.lua",
}
