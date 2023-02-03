--------------------------------------
--<!>-- ASTUDIOS | DEVELOPMENT --<!>--
--------------------------------------

fx_version 'adamant'

game 'gta5'

author 'Aqade_#1337'

description 'ASTUDIOS | Development - Activity: Skating'

version '1.0.0'

lua54 'yes'

shared_scripts {
  'shared/*.lua',
}
client_scripts {
  'client/*.lua',
}
server_scripts {
  'server/*.lua'
}

escrow_ignore {
  'shared/*'
}