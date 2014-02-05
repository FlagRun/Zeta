God.watch do |w|
  w.name = 'Zbot'
  w.start = 'ruby /home/liothen/Zbot/zbot.rb'
  w.keepalive(:memory_max => 150.megabytes)
end