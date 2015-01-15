name             "hana"
maintainer       "Andreas Bloemeke, Thomas Graichen, Harald Kuersten"
maintainer_email "andreas.bloemeke@sap.com, thomas.graichen@sap.com, harald.kuersten@sap.com"
license          ""
description      "Install/upgrade SAP Hana and SAP Hana client"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "2.02.37"
recipe           "hana::install", "Installs a vanilla SAP Hana on the node"
recipe           "hana::install-worker", "Installs a vanilla SAP Hana worker on the node"
recipe           "hana::install-client", "Installs SAP Hana client on the node"
recipe           "hana::install-lifecyclemngr", "Installs SAP Hana lifecycle manager on the node"
recipe           "hana::upgrade", "Upgrades an existing SAP Hana installation"
recipe           "hana::upgrade-client", "Upgrades an existing SAP Hana client installation"

depends          "nfs"
depends          "sapinst"

supports         "suse"
