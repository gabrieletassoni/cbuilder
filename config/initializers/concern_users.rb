module ConcernUsers
  extend ActiveSupport::Concern

  included do
    # has_many :profiles, dependent: :destroy   # La "Caserma" dell'utente
    has_many :army_lists, dependent: :destroy # Le liste create
  end
end
