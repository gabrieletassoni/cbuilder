module RailsAdmin::RankCategory
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.registries.label")
      navigation_icon "fa fa-layer-group"
    end
  end
end
