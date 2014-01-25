class User
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :quotes

  field :channel,    type: String
  field :nick,       type: String
  field :user,       type: String
  field :real,       type: String
  field :host,       type: String
  field :auth,       type: String
  field :role,       type: String,  default: 'nobody'
  field :ircop,      type: Boolean, default: false

  ## roles
  def is_owner?
    true if role.to_sym == :q
  end

  def is_admin?
    true if role.to_sym == :q || :a
  end

  def is_op?
    true if role.to_sym == :q || :a || :o
  end

  def is_halop?
    true if role.to_sym == :q || :a || :o || :h
  end

  def is_voice?
    true if role.to_sym == :q || :a || :o || :h || :v
  end

  def is_nobody?
    true if self.role == 'nobody' || self.role.nil?
  end

  def is_ircop?
    # Always obey the cops
    self.ircop
  end

  ## Display the Role
  def level
    return 'nobody' if role.nil?

    case role.to_sym
      when :q
        'Owner'
      when :a
        'Admin'
      when :o
        'Operator'
      when :h
        'Half-Op'
      when :v
        'Voiced'
      else
        'nobody'
    end
  end

end