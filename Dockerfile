# The most minimumalistic dockerfile possible.
#  No embedded python support, no unit-testing, no aliases.

ARG IMAGE=intersystemsdc/iris-community:2026.1
FROM $IMAGE

USER root


# Copy application sources and initialization assets
COPY src /src
COPY web /usr/irissys/csp/myapp
COPY myapp.cpf /tmp/myapp.cpf
COPY iris.script /tmp/iris.script

RUN chown -R irisowner:irisowner /src /usr/irissys/csp/myapp /tmp/myapp.cpf /tmp/iris.script

USER irisowner

# Create MYAPP and import /src during image build.
RUN iris start IRIS quietly \
 && iris merge IRIS /tmp/myapp.cpf \
 && iris session IRIS < /tmp/iris.script \
 && iris stop IRIS quietly \
 && rm /tmp/myapp.cpf /tmp/iris.script
