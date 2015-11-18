name             "hana"
maintainer       "Haggai Philip Zagury"
maintainer_email "haggai.zagury@sap.com"
license          "Apache 2.0"
description      "Install/upgrade SAP Hana and SAP Hana client"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"
recipe           "hana::install", "Installs a vanilla SAP Hana on the node"
recipe           "hana::install-worker", "Installs a vanilla SAP Hana worker on the node"
recipe           "hana::install-client", "Installs SAP Hana client on the node"
recipe           "hana::install-lifecyclemngr", "Installs SAP Hana lifecycle manager on the node"
recipe           "hana::upgrade", "Upgrades an existing SAP Hana installation"
recipe           "hana::upgrade-client", "Upgrades an existing SAP Hana client installation"
recipe           "hana::install-s4h-db-cal", "installs a S4H HANA DB from a CAL image"
%w{ suse }.each do |os|
  supports os
end