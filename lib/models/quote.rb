class Quote
  include Mongoid::Document

  embedded_in :user
end