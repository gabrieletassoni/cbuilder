module RailsAdmin::StatDefinition
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.registries.label")
      navigation_icon "fa fa-bars-progress"
    end
  end
end
