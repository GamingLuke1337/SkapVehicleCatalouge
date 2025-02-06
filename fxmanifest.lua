fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Skap'
description 'VehicleCatalouge for QB / ESX'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua' -- remove if not using ox_lib
}

client_scripts {
    'client/main.lua',
    'locales/*.lua'
}

server_script 'server/main.lua'
