module Abilities
  class Cbuilder
    include CanCan::Ability

    def initialize(user)
      if user.present?
        can :manage, :all
        # Users' abilities
        if user.admin?
          # Admins' abilities
        end
      end
    end
  end
end
