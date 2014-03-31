# Load Users
@owners             = Zconf.roles.owner.split(' ') rescue ''
@admins             = Zconf.roles.admin.split(' ') rescue ''
@operators          = Zconf.roles.operator.split(' ') rescue ''
@halfop             = Zconf.roles.halfop.split(' ') rescue ''
@voices             = Zconf.roles.voice.split(' ')  rescue ''