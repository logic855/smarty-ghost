#!/usr/bin/bash

## Download and install Ghost (https://ghost.org) on a Joyent SmartOS instance.

set -o errexit
set -o xtrace

# Set common vars. Change these as required.
pkgpath=/opt/local
ghosthome=/home/admin
ghostversion=0.4.1
WD=$(pwd)
publicIP=$(mdata-get sdc:nics.0.ip)
HOSTNAME=example.com
URL=http://${HOSTNAME}

# Ensure the latest version of Node.js is installed, as well as other required
# packages.
pkgin -y update
pkgin -y full-upgrade
pkgin -y install nodejs curl unzip gmake gcc47

# Set hostname
sm-set-hostname ${HOSTNAME}

# Dowload and unzip ghost
${pkgpath}/bin/curl -o ${ghosthome}/ghost.zip -L \
  https://ghost.org/zip/ghost-${ghostversion}.zip

${pkgpath}/bin/unzip ${ghosthome}/ghost.zip -d ${ghosthome}/ghost

cd ${ghosthome}/ghost
npm install --production
cd $HOME

# Create Ghost config
cat << ghostconfig > ${ghosthome}/ghost/config.js
var path = require('path'),
    config;

config = {
    production: {
        url: '$URL',
        database: {
            client: 'sqlite3',
            connection: {
                filename: path.join(__dirname, '/content/data/ghost.db')
            },
            debug: false
        },
        server: {
            host: '$publicIP',
            port: '80'
        }
    }

};

module.exports = config;
ghostconfig

chown admin:staff -R ${ghosthome}/ghost/

# Create SMF manifest for Ghost service
cat << SMF > ${ghosthome}/ghost/ghost.xml
<?xml version="1.0"?>
<!DOCTYPE service_bundle SYSTEM '/usr/share/lib/xml/dtd/service_bundle.dtd.1'>
<service_bundle type="manifest" name="ghost">
    <service name="site/ghost" type="service" version="1">
        <create_default_instance enabled="true"/>
        <single_instance/>
        <dependency name="network" grouping="require_all" restart_on="error" type="service">
            <service_fmri value="svc:/milestone/network:default"/>
        </dependency>
        <dependency name="filesystem" grouping="require_all" restart_on="error" type="service">
            <service_fmri value="svc:/system/filesystem/local"/>
        </dependency>
        <method_context working_directory="$ghosthome/ghost">
            <method_credential user="admin" group="staff" privileges="basic,net_privaddr"/>
            <method_environment>
                <envvar name="PATH" value="/opt/local/sbin:/opt/local/bin:/usr/sbin:/usr/bin/" />
                <envvar name="NODE_ENV" value="production"/>
            </method_environment>
        </method_context>
        <exec_method type="method" name="start" exec="node index.js" timeout_seconds="60"/>
        <exec_method type="method" name="stop" exec=":kill" timeout_seconds="60"/>
        <property_group name="startd" type="framework">
            <propval name="duration" type="astring" value="child"/>
            <propval name="ignore_error" type="astring" value="core,signal"/>
        </property_group>
        <stability value="Evolving"/>
        <template>
            <common_name>
                <loctext xml:lang="C">
                    Ghost
                </loctext>
            </common_name>
            <documentation>
              <doc_link name="ghost.org" uri="http://docs.ghost.org" />
            </documentation>
        </template>
    </service>
</service_bundle>
SMF

chown admin:staff ${ghosthome}/ghost/ghost.xml

# Install and enble the SMF service for Ghost
svccfg import ${ghosthome}/ghost/ghost.xml
svcadm enable ghost

echo ""
echo "Ghost is now installed and available at http://$publicIP/"
echo ""

exit 0
