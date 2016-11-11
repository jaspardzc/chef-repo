name 'dev_restseed_cb'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
description 'Installs/Configures dev_restseed_cb'
long_description 'Installs/Configures dev_restseed_cb'
version '0.1.0'

# manage cookbook dependencies
depends 'dev_docker_cb'
depends 'dev_tomcat_cb'
depends 'dev_artifactory_cb'

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Issues` link
# issues_url 'https://github.com/<insert_org_here>/dev_restseed_cb/issues' if respond_to?(:issues_url)

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Source` link
# source_url 'https://github.com/<insert_org_here>/dev_restseed_cb' if respond_to?(:source_url)
