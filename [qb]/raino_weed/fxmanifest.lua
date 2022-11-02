fx_version 'cerulean'
game 'gta5'

description 'Klovnens Weedscript'
version '1.0'

shared_scripts {
    'config.lua',
    '@raino_core/shared/locale.lua',
    'locales/no.lua',
    'locales/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_script 'client/main.lua'

lua54 'yes'