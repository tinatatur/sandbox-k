# What `myapp.cpf` Is For

This document is only an explanation of the template configuration. You do not need to run these lines manually during deployment.

`myapp.cpf` is a configuration merge file for InterSystems IRIS. During the Docker image build, the Dockerfile runs:

```bash
iris merge IRIS /tmp/myapp.cpf
```

That command applies the settings from `myapp.cpf` to the IRIS instance. In this template, the file creates the application namespace, enables interoperability support, and defines the web applications used by the UI and REST API.

## `myapp.cpf` Actions

```ini
[Actions]
```

Starts the configuration merge actions section. The lines below it are executed by IRIS during the merge.

```ini
CreateResource:Name=%DB_MYAPP,PublicPermission=
```

Creates the `%DB_MYAPP` database resource with no public permissions. This resource is used to protect the application database.

```ini
CreateDatabase:Name=MYAPP,Directory=/usr/irissys/mgr/MYAPP,ResourceName=%DB_MYAPP
```

Creates the `MYAPP` database in `/usr/irissys/mgr/MYAPP`. This database stores the application globals and routines, and is protected by the `%DB_MYAPP` resource.

```ini
CreateNamespace:Name=MYAPP,Globals=MYAPP,Routines=MYAPP,Interop=1
```

Creates the `MYAPP` namespace. It uses the `MYAPP` database for globals and routines. `Interop=1` enables the namespace for InterSystems interoperability productions.

```ini
CreateDatabase:Name=MYAPP_DATAENSTEMP,Directory=/usr/irissys/mgr/MYAPP_DATAENSTEMP
```

Creates an additional database used by interoperability-related configuration.

```ini
CreateDatabase:Name=MYAPP_DATASECONDARY,Directory=/usr/irissys/mgr/MYAPP_DATASECONDARY
```

Creates another additional database used by interoperability-related configuration.

```ini
CreateRole:Name=MYAPP_API,Resources=%DB_MYAPP:RW
```

Creates the `MYAPP_API` role for the REST application. The role grants read and write access only to the `MYAPP` database resource, `%DB_MYAPP`, instead of granting a broad superuser role.

```ini
CreateApplication:Name=/myapp,NameSpace=MYAPP,Path=/usr/irissys/csp/myapp,CSPZENEnabled=1,Enabled=1,ServeFiles=1,AutheEnabled=64,Recurse=1
```

Creates the `/myapp` web application. It serves files from `/usr/irissys/csp/myapp`, which is where the Dockerfile copies the `web` folder. `ServeFiles=1` allows static files such as `index.html` to be served.

```ini
CreateApplication:Name=/myapp/api,NameSpace=MYAPP,DispatchClass=Sandbox.Cloudsample.REST,CSPZENEnabled=1,Enabled=1,AutheEnabled=64,MatchRoles=:MYAPP_API
```

Creates the `/myapp/api` REST application. Requests are dispatched to `Sandbox.Cloudsample.REST`. In this template, `GET /myapp/api/test` returns a JSON status response. `MatchRoles=:MYAPP_API` adds only the application role needed to access the template database while the request is handled by this application.
