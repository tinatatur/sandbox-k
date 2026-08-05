# Sandbox Cloud Template

This repository is a starter template for deploying an InterSystems IRIS application to the InterSystems Developer Sandbox with GitHub Actions.

It includes a small sample application, an IRIS configuration merge file, a Docker-based local development setup, and the files needed to turn a new GitHub repository into a Sandbox deployment.

## What You Get

- An InterSystems IRIS application namespace named `MYAPP`.
- A static web application served from `/myapp`.
- A sample REST API at `/myapp/api/test`.
- A Dockerfile that creates the namespace, applies `myapp.cpf`, imports ObjectScript classes, and builds the image.
- A local `docker-compose.yml` setup with localhost-only ports and an application healthcheck.
- Optional VS Code Dev Containers support in `.devcontainer/devcontainer.json`.

## Architecture

```mermaid
flowchart LR
    user[Developer] --> repo[New GitHub repo from template]
    repo --> actions[GitHub Actions deploy workflow]
    actions --> sandbox[InterSystems Developer Sandbox]
    sandbox --> iris[IRIS container]
    iris --> web[/myapp static web app]
    iris --> api[/myapp/api REST API]
    api --> db[(MYAPP database)]
```

The template is meant to be copied with **Use this template**. After that, you connect the new repository to an InterSystems Developer Sandbox deployment by adding a service account key and pasting the generated deployment workflow into `.github/workflows/deploy.yml`.

## Sample App

The sample REST class is in:

```text
src/sandbox/cloudsample/REST.cls
```

It defines:

```http
GET /myapp/api/test
```

Expected response:

```json
{"status":"OK"}
```

Static web files live in:

```text
web/
```

The Dockerfile copies that folder to `/usr/irissys/csp/myapp`, so the app is served from `/myapp`.

## Add Your Classes

Put your ObjectScript classes under:

```text
src/
```

During the Docker build, `iris.script` recursively imports and compiles all `.cls` files from `/src`. The sample REST class shows the expected layout:

```text
src/sandbox/cloudsample/REST.cls
```

## Project Layout

```text
.
|-- .devcontainer/                 Optional VS Code Dev Container config
|-- .github/workflows/deploy.yml    Sandbox deployment workflow placeholder
|-- .vscode/                        Recommended VS Code settings
|-- src/                            ObjectScript source classes
|-- web/                            Static files served by /myapp
|-- Dockerfile                      Builds the IRIS application image
|-- docker-compose.yml              Local development runtime
|-- iris.script                     Imports and compiles classes during build
|-- myapp.cpf                       IRIS configuration merge file
`-- MYAPP_CPF.md                    Detailed configuration reference
```

## Deploy To Developer Sandbox

1. Sign in to GitHub.

2. Open the template repository:

   <https://github.com/nsolov/sandbox-cloud-template>

3. Click **Use this template**, then select **Create a new repository**.

4. Fill in the repository creation form.

   You can create either a public or a private repository. After submitting the form, GitHub will open your newly created repository.

   You may receive a **Run failed** email notification from GitHub. This is expected at this stage because the deployment settings have not been configured yet.

5. Open the InterSystems Developer Sandbox deployments page:

   <https://cloud.sandbox.developer.intersystems.com/portal/deployments>

6. Create a new deployment and generate a service account key.

7. Save the service account key in GitHub:

   - In your repository, open **Settings**.
   - In the left menu, select **Secrets and variables**, then **Actions**.
   - Click **New repository secret**.
   - Set **Name** to:

     ```text
     SERVICE_ACCOUNT_KEY
     ```

   - In **Secret**, paste the complete contents of the key file created in the previous step.

8. Configure the deployment workflow:

   - In your repository, open the **Code** tab.
   - Open the `.github/workflows` folder.
   - Open `deploy.yml`.
   - The file is initially empty.
   - Click the pencil icon to edit the file.
   - Paste the full contents of the `deploy.yml` block from the deployment creation page.
   - Recommended, but optional: uncomment the following line to allocate 1 GiB of memory:

     ```yaml
     memory: 1Gi
     ```

   - Click **Commit changes**.
   - Use **Commit directly to the master branch**.

9. Open the **Actions** tab in GitHub.

10. Wait until the latest workflow run completes successfully and turns green.

11. Check the status of your deployment. The deployment update may take several minutes:

    <https://cloud.sandbox.developer.intersystems.com/portal/deployments>

12. Open the InterSystems IRIS Management Portal using the link shown for your deployment in the Developer Sandbox portal. Sign in with the default credentials, then change the default `_SYSTEM` password to your own unique password. The default credentials are:

    ```text
    Username: _SYSTEM
    Password: SYS
    ```

## Local Development

You can run the same application locally with Docker Compose:

```bash
docker compose up --build
```

The local ports are bound to `127.0.0.1` only:

```text
127.0.0.1:1972   IRIS SuperServer
127.0.0.1:52773  Web server and Management Portal
127.0.0.1:53773  Additional IRIS web port
```

Open the static app:

```text
http://127.0.0.1:52773/myapp/
```

Check the REST API:

```bash
curl http://127.0.0.1:52773/myapp/api/test
```

Docker Compose also includes a healthcheck that calls `/myapp/api/test`. Check container health with:

```bash
docker compose ps
```

Stop the local environment with:

```bash
docker compose down
```

## Configuration

The main IRIS configuration file is:

```text
myapp.cpf
```

It is applied during the Docker build with:

```bash
iris merge IRIS /tmp/myapp.cpf
```

The file creates the `MYAPP` database and namespace, configures the `/myapp` static web application, configures the `/myapp/api` REST application, and grants the REST application a least-privilege application role instead of `%All`.

For a line-by-line explanation, see [What `myapp.cpf` Is For](MYAPP_CPF.md).

## Troubleshooting

### GitHub Action Fails Immediately

If the workflow runs before you configure the Sandbox deployment settings, this is expected. Add the `SERVICE_ACCOUNT_KEY` secret and paste the generated deployment workflow into `.github/workflows/deploy.yml`, then run the workflow again.

### Missing Or Invalid `SERVICE_ACCOUNT_KEY`

Make sure the repository secret is named exactly:

```text
SERVICE_ACCOUNT_KEY
```

Paste the complete contents of the service account key file into the secret value.

### Docker Port Is Already In Use

If Docker reports that a port is already allocated, another local container or process is using one of these ports:

```text
1972, 52773, 53773
```

Stop the other process or change the host-side port in `docker-compose.yml`.

### Container Is Unhealthy

Check the logs:

```bash
docker compose logs iris
```

The healthcheck calls:

```text
http://127.0.0.1:52773/myapp/api/test
```

If this endpoint fails, check whether IRIS started successfully, whether `myapp.cpf` merged successfully, and whether the ObjectScript classes compiled.

### IRIS Merge Failed

A merge failure usually points to a problem in `myapp.cpf`. The Docker build log includes the failing action and line number. Fix `myapp.cpf`, then rebuild:

```bash
docker compose build --no-cache iris
```

### REST Endpoint Returns 404

Check that `Sandbox.Cloudsample.REST` compiled successfully and that `/myapp/api` exists in `myapp.cpf` with the expected `DispatchClass`.
