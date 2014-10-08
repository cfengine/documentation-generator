# This provisions a docker image from Ubuntu 12, installs required
# tools, checks out repositories and runs all processes required to
# build the documentation. It then launches a web server that serves
# the documentation.

FROM vohi/cfengine:doc-base
MAINTAINER Volker Hilsheimer <volker.hilsheimer@gmail.com>
