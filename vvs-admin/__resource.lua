resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

client_scripts {
    'client/client.lua',
    'config.lua',
    'client/adminkomande_cl.lua',
    'client/tag_cl.lua'
}

server_scripts {
    'server/adminkomande_sv.lua',
    'server/server.lua',
    'config.lua',
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
}

shared_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua'
}