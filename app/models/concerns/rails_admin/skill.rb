module RailsAdmin::Skill
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.equipment_and_mysticism.label")
      navigation_icon "fa fa-fingerprint"

      configure :skill_target do
        queryable true
        searchable :name
      end
    end
  end
end
