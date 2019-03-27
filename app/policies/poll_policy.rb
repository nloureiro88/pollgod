class PollPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  # Poll creation

  def new?
    create?
  end

  def create?
    true
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

  def report?
    true
  end

  # Poll inactivation

  def toggle?
    true
  end

  def destroy?
    true
  end
end
