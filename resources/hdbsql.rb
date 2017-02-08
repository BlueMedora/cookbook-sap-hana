actions :run

attribute :name, :kind_of => String, :name_attribute => true
attribute :sql_command, :kind_of => String, :default => ""
attribute :sql_file_path, :kind_of => String, :default => ""
attribute :sql_file_command_separator, :kind_of => String, :default => ";"

attribute :username, :kind_of => String, :default => ""
attribute :password, :kind_of => String, :default => ""
attribute :host, :kind_of => String, :default => "localhost"
attribute :instance_number, :kind_of => String, :default => "00"
attribute :print_sql_commands, :kind_of => [TrueClass, FalseClass], :default => true
attribute :print_table_header, :kind_of => [TrueClass, FalseClass], :default => true
attribute :output_file_path, :kind_of => String
attribute :expected_exit_codes, :kind_of => Array

def initialize(*args)
  super
  @action = :run
end
