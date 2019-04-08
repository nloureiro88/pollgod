class ProfilePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def dash?
    true
  end

  def go_pro?
    true
  end

  def go_premium?
    true
  end

  def filter_toggle?
    true
  end

  def filter_all?
    true
  end
end
