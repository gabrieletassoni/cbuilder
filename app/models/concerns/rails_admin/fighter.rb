module RailsAdmin::Fighter
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.core_entities.label")
      navigation_icon "fa fa-user-ninja"

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
    end
  end
end
