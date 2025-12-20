fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_fxv2_oal 'yes'

name 'wine production system'
author 'gandalfthegreet and skeezle'
version '1.0.0'

shared_scripts{
    '@ox_lib/init.lua',
    'config.lua',
    'shared.lua'
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

dependencies {
    'qb-core',
    'ox_inventory',
    'ox_lib',
    'ox_target'
}
