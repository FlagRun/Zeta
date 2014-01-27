module Admin
  class UserAdmin
    include Cinch::Plugin



    private
    def getuser(m)
      ZUser.where(nick: m.user.nick).first || ZUser.new
    end
  end
end