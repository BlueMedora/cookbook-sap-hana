actions :update_hlm, :add_afl, :add_lca, :add_sda, :apply_sp, :deploy_content, :add_host, :add_system, :remove_host, :remove_system, :rename

default_action :update_hlm

def initialize(*args)
  super
  @action = :update_hlm
end

# Sources
attribute :update_source, :kind_of => String, :default => "marketplace", :equal_to => ["marketplace", "inbox"]
attribute :archive_path, :kind_of => String

# Proxy
attribute :use_proxy, :kind_of => [TrueClass, FalseClass], :default => true
attribute :proxy_host, :kind_of => String, :default => "proxy.wdf.sap.corp"
attribute :proxy_port, :kind_of => Fixnum, :default => 8080

# Service Marketplace
attribute :smp_user, :kind_of => String
attribute :smp_pass, :kind_of => String

# sapadm
attribute :sapadm_pass, :kind_of => String

# additional host
attribute :hostname, :kind_of => String
attribute :role, :kind_of => String, :equal_to => ["worker", "standby"]

attribute :target_memory, :kind_of => String
attribute :target_sid, :kind_of => String
attribute :target_instance, :kind_of => Fixnum
attribute :target_datapath, :kind_of => String
attribute :target_logpath, :kind_of => String
attribute :target_pass, :kind_of => String
