class Chatlog
  include Mongoid::Document

  field :channel,   type: String
  field :time,      type: DateTime
  field :nick,      type: String
  field :msg,       type: String

  field :quote,     type: Boolean, default: false

end