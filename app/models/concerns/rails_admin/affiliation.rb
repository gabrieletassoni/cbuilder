module RailsAdmin::Affiliation
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.core_entities.label")
      navigation_icon "fa fa-people-roof"

      parent Army

      configure :affiliation_leaders do
        visible false
      end
    end
  end
end
