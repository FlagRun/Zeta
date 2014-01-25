module Admin
  class UserAdmin
    include Cinch::Plugin



    private
    def getuser(m)
      User.where(nick: m.user.nick).first || User.new
    end
  end
end