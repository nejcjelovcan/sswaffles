require 'naught'

module SSWaffles
  GrantBuilder = Naught.build

  class AccessControlList

    def grant(*args); GrantBuilder.new; end

  end
end