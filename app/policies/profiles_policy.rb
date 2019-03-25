class ProfilesPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def dash?
    true
  end

  def filter_toggle?
    true
  end
end
