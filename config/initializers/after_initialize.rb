Rails.application.configure do
  config.after_initialize do
    # Hide all the created_at and updated_at fields from RailsAdmin
    RailsAdmin.config do |config|
      config.models.each do |model|
        model.exclude_fields :created_at, :updated_at if model.fields.map(&:name).include?(:created_at) && model.fields.map(&:name).include?(:updated_at)
      end
    end
    # For example, it can be used to load a root action defined in lib, for example:
    # require 'root_actions/tcp_debug'
    User.send(:include, ConcernUsers)
  end
end
