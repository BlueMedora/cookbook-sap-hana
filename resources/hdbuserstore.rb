actions :set, :delete

attribute :key, :kind_of => String, :name_attribute => true
attribute :username, :kind_of => String, :default => ""
attribute :password, :kind_of => String, :default => ""
attribute :host, :kind_of => String, :default => "localhost"
attribute :instance_number, :kind_of => String, :default => "00"
