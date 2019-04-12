class FriendPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def add?
    true
  end

  def remove?
    true
  end
end
