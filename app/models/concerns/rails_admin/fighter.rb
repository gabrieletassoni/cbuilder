module RailsAdmin::Fighter
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.core_entities.label")
      navigation_icon "fa fa-user-ninja"

      parent Army

      # hide created_at and updated_at
      exclude_fields :created_at, :updated_at

      configure :name do
        sticky true
      end
      configure :affiliation_leaders do
        visible false
      end
      configure :profiles do
        visible false
      end
      configure :requirements_as_target do
        visible false
      end
      configure :miracles do
        visible false
      end
      configure :spells do
        visible false
      end
      configure :fighters_skills do
        visible false
      end

      configure :army do
        queryable true
        searchable :name
      end

      configure :affiliation do
        queryable true
        searchable :name
      end

      configure :rank do
        queryable true
        searchable :name
      end
      configure :size do
        queryable true
        searchable :name
      end

      # configure :granted_equipments do
      #   queryable true
      #   searchable :name
      # end
      # configure :granted_skills do
      #   queryable true
      #   searchable :name
      # end
      # configure :granted_magic_paths do
      #   queryable true
      #   searchable :name
      # end
      # configure :granted_deities do
      #   queryable true
      #   searchable :name
      # end
      configure :keywords do
        queryable true
        searchable :name
      end
    end
  end
end
