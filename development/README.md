# Getting Started

## Prerequisites

In order to start developing you need to satisfy the following prerequisites:

- Docker
- docker-compose
- user added to docker group

It is recommended you allocate at least 4GB of RAM to docker:

- [Instructions for Windows](https://docs.docker.com/docker-for-windows/#resources)
- [Instructions for macOS](https://docs.docker.com/docker-for-mac/#resources)

## Bootstrap Containers for development

Clone and change directory to frappe_docker directory

```shell
git clone https://github.com/frappe/frappe_docker.git
cd frappe_docker
```

Copy example devcontainer config from `devcontainer-example` to `.devcontainer`

```shell
cp -R devcontainer-example .devcontainer
```

Copy example vscode config for devcontainer from `development/vscode-example` to `development/.vscode`. This will setup basic configuration for debugging.

```shell
cp -R development/vscode-example development/.vscode
```

## Use VSCode Remote Containers extension

For most people getting started with Frappe development, the best solution is to use [VSCode Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

Before opening the folder in container, determine the database that you want to use. The default is MariaDB.
If you want to use PostgreSQL instead, edit `.devcontainer/docker-compose.yml` and uncomment the section for `postgresql` service, and you may also want to comment `mariadb` as well.

VSCode should automatically inquire you to install the required extensions, that can also be installed manually as follows:

- Install Remote - Containers for VSCode
  - through command line `code --install-extension ms-vscode-remote.remote-containers`
  - clicking on the Install button in the Vistual Studio Marketplace: [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
  - View: Extensions command in VSCode (Windows: Ctrl+Shift+X; macOS: Cmd+Shift+X) then search for extension `ms-vscode-remote.remote-containers`

After the extensions are installed, you can:

- Open frappe_docker folder in VS Code.
  - `code .`
- Launch the command, from Command Palette (Ctrl + Shift + P) `Remote-Containers: Reopen in Container`. You can also click in the bottom left corner to access the remote container menu.

Notes:

- The `development` directory is ignored by git. It is mounted and available inside the container. Create all your benches (installations of bench, the tool that manages frappe) inside this directory.
- Node v14 and v10 are installed. Check with `nvm ls`. Node v14 is used by default.

### Setup first bench

Run the following commands in the terminal inside the container. You might need to create a new terminal in VSCode.

```shell
bench init --skip-redis-config-generation frappe-bench
cd frappe-bench
```

For version 13 use Python 3.9 by passing option to `bench init` command,

```shell
bench init --skip-redis-config-generation --frappe-branch version-13 --python python3.9 frappe-bench
cd frappe-bench
```

For version 12 use Python 3.7 by passing option to `bench init` command,

```shell
bench init --skip-redis-config-generation --frappe-branch version-12 --python python3.7 frappe-bench
cd frappe-bench
```

### Setup hosts

We need to tell bench to use the right containers instead of localhost. Run the following commands inside the container:

```shell
bench set-config -g db_host mariadb
bench set-config -g redis_cache redis://redis-cache:6379
bench set-config -g redis_queue redis://redis-queue:6379
bench set-config -g redis_socketio redis://redis-socketio:6379
```

For any reason the above commands fail, set the values in `common_site_config.json` manually.

```json
{
  "db_host": "mariadb",
  "redis_cache": "redis://redis-cache:6379",
  "redis_queue": "redis://redis-queue:6379",
  "redis_socketio": "redis://redis-socketio:6379"
}
```

### Edit Honcho's Procfile

Note : With the option '--skip-redis-config-generation' during bench init, these actions are no more needed. But at least, take a look to ProcFile to see what going on when bench launch honcho on start command

Honcho is the tool used by Bench to manage all the processes Frappe requires. Usually, these all run in localhost, but in this case, we have external containers for Redis. For this reason, we have to stop Honcho from trying to start Redis processes.

Honcho is installed in global python environment along with bench. To make it available locally you've to install it in every `frappe-bench/env` you create. Install it using command `./env/bin/pip install honcho`. It is required locally if you wish to use is as part of VSCode launch configuration.

Open the Procfile file and remove the three lines containing the configuration from Redis, either by editing manually the file:

```shell
code Procfile
```

Or running the following command:

```shell
sed -i '/redis/d' ./Procfile
```

### Create a new site with bench

You can create a new site with the following command:

```shell
bench new-site sitename --no-mariadb-socket
```

sitename MUST end with .localhost for trying deployments locally.

for example:

```shell
bench new-site mysite.localhost --no-mariadb-socket
```

The same command can be run non-interactively as well:

```shell
bench new-site mysite.localhost --mariadb-root-password 123 --admin-password admin --no-mariadb-socket
```

The command will ask the MariaDB root password. The default root password is `123`.
This will create a new site and a `mysite.localhost` directory under `frappe-bench/sites`.
The option `--no-mariadb-socket` will configure site's database credentials to work with docker.
You may need to configure your system /etc/hosts if you're on Linux, Mac, or its Windows equivalent.

To setup site with PostgreSQL as database use option `--db-type postgres` and `--db-host postgresql`. (Available only v12 onwards, currently NOT available for ERPNext).

Example:

```shell
bench new-site mypgsql.localhost --db-type postgres --db-host postgresql
```

To avoid entering postgresql username and root password, set it in `common_site_config.json`,

```shell
bench config set-common-config -c root_login postgres
bench config set-common-config -c root_password '"123"'
```

Note: If PostgreSQL is not required, the postgresql service / container can be stopped.

### Set bench developer mode on the new site

To develop a new app, the last step will be setting the site into developer mode. Documentation is available at [this link](https://frappe.io/docs/user/en/guides/app-development/how-enable-developer-mode-in-frappe).

```shell
bench --site mysite.localhost set-config developer_mode 1
bench --site mysite.localhost clear-cache
```

### Install an app

To install an app we need to fetch it from the appropriate git repo, then install in on the appropriate site:

You can check [VSCode container remote extension documentation](https://code.visualstudio.com/docs/remote/containers#_sharing-git-credentials-with-your-container) regarding git credential sharing.

To install custom app

```shell
# --branch is optional, use it to point to branch on custom app repository
bench get-app --branch version-12 https://github.com/myusername/myapp
bench --site mysite.localhost install-app myapp
```

To install ERPNext (from the version-13 branch):

```shell
bench get-app --branch version-13 erpnext
bench --site mysite.localhost install-app erpnext
```

Note: Both frappe and erpnext must be on branch with same name. e.g. version-12

### Start Frappe without debugging

Execute following command from the `frappe-bench` directory.

```shell
bench start
```

You can now login with user `Administrator` and the password you choose when creating the site.
Your website will now be accessible at location [mysite.localhost:8000](http://mysite.localhost:8000)
Note: To start bench with debugger refer section for debugging.

### Start Frappe with Visual Studio Code Python Debugging

To enable Python debugging inside Visual Studio Code, you must first install the `ms-python.python` extension inside the container. This should have already happened automatically, but depending on your VSCode config, you can force it by:

- Click on the extension icon inside VSCode
- Search `ms-python.python`
- Click on `Install on Dev Container: Frappe Bench`
- Click on 'Reload'

We need to start bench separately through the VSCode debugger. For this reason, **instead** of running `bench start` you should run the following command inside the frappe-bench directory:

```shell
honcho start \
    socketio \
    watch \
    schedule \
    worker_short \
    worker_long \
    worker_default
```

Alternatively you can use the VSCode launch configuration "Honcho SocketIO Watch Schedule Worker" which launches the same command as above.

This command starts all processes with the exception of Redis (which is already running in separate container) and the `web` process. The latter can can finally be started from the debugger tab of VSCode by clicking on the "play" button.

You can now login with user `Administrator` and the password you choose when creating the site, if you followed this guide's unattended install that password is going to be `admin`.

To debug workers, skip starting worker with honcho and start it with VSCode debugger.

For advance vscode configuration in the devcontainer, change the config files in `development/.vscode`.

## Developing using the interactive console

You can launch a simple interactive shell console in the terminal with:

```shell
bench --site mysite.localhost console
```

More likely, you may want to launch VSCode interactive console based on Jupyter kernel.

Launch VSCode command palette (cmd+shift+p or ctrl+shift+p), run the command `Python: Select interpreter to start Jupyter server` and select `/workspace/development/frappe-bench/env/bin/python`.

The first step is installing and updating the required software. Usually the frappe framework may require an older version of Jupyter, while VSCode likes to move fast, this can [cause issues](https://github.com/jupyter/jupyter_console/issues/158). For this reason we need to run the following command.

```shell
/workspace/development/frappe-bench/env/bin/python -m pip install --upgrade jupyter ipykernel ipython
```

Then, run the command `Python: Show Python interactive window` from the VSCode command palette.

Replace `mysite.localhost` with your site and run the following code in a Jupyter cell:

```python
import frappe

frappe.init(site='mysite.localhost', sites_path='/workspace/development/frappe-bench/sites')
frappe.connect()
frappe.local.lang = frappe.db.get_default('lang')
frappe.db.connect()
```

The first command can take a few seconds to be executed, this is to be expected.

## Manually start containers

In case you don't use VSCode, you may start the containers manually with the following command:

### Running the containers

```shell
docker-compose -f .devcontainer/docker-compose.yml up -d
```

And enter the interactive shell for the development container with the following command:

```shell
docker exec -e "TERM=xterm-256color" -w /workspace/development -it devcontainer-frappe-1 bash
```

## Use additional services during development

Add any service that is needed for development in the `.devcontainer/docker-compose.yml` then rebuild and reopen in devcontainer.

e.g.

```yaml
...
services:
 ...
  postgresql:
    image: postgres:11.8
    environment:
      POSTGRES_PASSWORD: 123
    volumes:
      - postgresql-data:/var/lib/postgresql/data
    ports:
      - 5432:5432

volumes:
  ...
  postgresql-data:
```

Access the service by service name from the `frappe` development container. The above service will be accessible via hostname `postgresql`. If ports are published on to host, access it via `localhost:5432`.
