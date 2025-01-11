
-- Fxmanifest.lua Info --

fx_version 'cerulean'
game 'gta5'

name 'Sunset Seatbelt'
author 'Sunset_Nathan'
description 'DOJRP-style Seatbelt Script.'
version '1.0.0'

-- Client Side --

client_scripts {
    'config/config.lua',
    'client/client.lua'
}

-- Server Side --

server_scripts {
    'server/server.lua'
}

-- Script Files --

files {
    'client/ui/index.html',
    'client/ui/css/style.css',
    'client/ui/js/script.js',
    'client/ui/image/seatbelt.png',
    'client/ui/sounds/buckle.ogg',
    'client/ui/sounds/unbuckle.ogg',
    'client/ui/sounds/warning.ogg'
}

-- UI Page --

ui_page 'client/ui/index.html'