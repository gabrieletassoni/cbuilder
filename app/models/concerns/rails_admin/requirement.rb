module RailsAdmin::Requirement
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.modification_engine.label")
      navigation_icon "fa fa-circle-exclamation"

      parent StatModifier

      configure :restrictable do
        visible false
      end
    end
  end
end
