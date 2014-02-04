class Zuser < Sequel::Model

  ## roles
  def is_owner?
    return false if role.nil?
    true if role.to_sym == :q
  end

  def is_admin?
    return false if role.nil?
    true if role.to_sym == :q || :a
  end

  def is_op?
    return false if role.nil?
    true if role.to_sym == :q || :a || :o
  end

  def is_halfop?
    return false if role.nil?
    true if role.to_sym == :q || :a || :o || :h
  end

  def is_voice?
    return false if role.nil?
    true if role.to_sym == :q || :a || :o || :h || :v
  end

  def is_nobody?
    return false if role.nil?
    true if self.role == 'nobody' || self.role.nil?
  end

  def is_ircop?
    return false if role.nil?
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