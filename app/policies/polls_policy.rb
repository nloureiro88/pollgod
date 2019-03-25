class PollsPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  # Poll detail

  def show?
    true
  end

  # Poll answer workflow

  def add_answer?
    true
  end

  def result?
    true
  end

  # Poll creation

  def new?
    create?
  end

  def create?
    true
  end

  # Poll inactivation

  def toggle?
    true
  end

  def delete?
    true
  end
end
