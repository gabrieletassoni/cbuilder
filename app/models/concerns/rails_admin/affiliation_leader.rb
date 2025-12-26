module RailsAdmin::AffiliationLeader
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.core_entities.label")
      navigation_icon "fa fa-mask"
    end
  end
end
