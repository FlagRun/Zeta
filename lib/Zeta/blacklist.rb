require 'fileutils'

BlackListStruct = Struct.new :channels, :users, :plugins, :urls, :masks

# Load Cached
if File.exist?(File.join(Dir.home, '.zeta', 'cache', 'blacklist.rb'))
  File.open(File.join(Dir.home, '.zeta', 'cache', 'blacklist.rb')) do |file|
    Blacklist = Marshal.load(file)
  end
else
  Blacklist = BlackListStruct.new([], [], [], [], [])
end


## Methods
def save_blacklist()
  File.open(File.join(Dir.home, '.zeta', 'cache', 'blacklist.rb'), 'w+') do |file|
    Marshal.dump(Blacklist, file)
  end
end

def clear_blacklist()
  Blacklist.users = []
  Blacklist.plugins = []
  Blacklist.channels = []
  Blacklist.urls = []
  Blacklist.masks = []
  FileUtils.rm_f(File.join(Dir.home, '.zeta', 'cache', 'blacklist.rb'))
end