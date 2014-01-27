class ZQuote
  include Mongoid::Document

  embedded_in :user
end