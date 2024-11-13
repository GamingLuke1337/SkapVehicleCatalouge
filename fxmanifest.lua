fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Skap'
description 'VehicleCatalouge for QBCore'
version '1.0.0'

shared_scripts {
    '@lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

dependency "lib" -- https://github.com/Jay60Dev/lib