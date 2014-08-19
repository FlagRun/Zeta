# Load Users
$owner             = Zconf.roles.owner
$admin             = Zconf.roles.admin.split(' ') || Array.new
$operator          = Zconf.roles.operator.split(' ') || Array.new