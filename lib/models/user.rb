class Zuser < Sequel::Model(:users)


  def nick(); nickname; end
  def user(); username; end
  def host(); hostname; end
  def auth(); authname; end

end