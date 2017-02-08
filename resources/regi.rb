actions :create_workspace, :delete_workspace,
        :export_delivery_unit, :import_delivery_unit,
        :track_package, :untrack_package, :delete_package,
        :checkout, :commit, :revert, :activate

attribute :name, :name_attribute => true

# this will containt the path to the regi workspace on the local file system
attribute :workspace_path, :kind_of => String, :required => true

# needed for create_workspace action
attribute :key, :kind_of => String

# needed for create_workspace action and checkout
attribute :force, :kind_of => [TrueClass, FalseClass], :default => true

# needed for import_delivery_unit / export_delivery_unit actions
attribute :delivery_unit_name, :kind_of => String
attribute :delivery_unit_vendor, :kind_of => String
attribute :delivery_unit_path, :kind_of => String

# needed for track, untrack, revert, activate and delete_package actions
attribute :package, :kind_of => String

# needed for delete_package action
attribute :cascade, :kind_of => [TrueClass, FalseClass], :default => true

# options here are inactiveObjects, trackedPackages
# used in revert and activate actions
attribute :object_type, :kind_of => String

# used in revert and activate actions
attribute :object, :kind_of => String
