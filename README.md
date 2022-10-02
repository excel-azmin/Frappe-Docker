[![Build Stable](https://github.com/frappe/frappe_docker/actions/workflows/build_stable.yml/badge.svg)](https://github.com/frappe/frappe_docker/actions/workflows/build_stable.yml)
[![Build Develop](https://github.com/frappe/frappe_docker/actions/workflows/build_develop.yml/badge.svg)](https://github.com/frappe/frappe_docker/actions/workflows/build_develop.yml)

Everything about [Frappe](https://github.com/frappe/frappe) and [ERPNext](https://github.com/frappe/erpnext) in containers.

# Getting Started

To get started, you need Docker, docker-compose and git setup on your machine. For Docker basics and best practices. Refer Docker [documentation](http://docs.docker.com).
After that, clone this repo:

```sh
git clone https://github.com/frappe/frappe_docker
cd frappe_docker
```

### Try in Play With Docker

<a href="https://labs.play-with-docker.com/?stack=https://raw.githubusercontent.com/frappe/frappe_docker/main/pwd.yml">
  <img src="https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png" alt="Try in PWD"/>
</a>

Wait for 5 minutes for ERPNext site to be created or check `create-site` container logs before opening browser on port 8080. (username: `Administrator`, password: `admin`)

# Development

We have baseline for developing in VSCode devcontainer with [frappe/bench](https://github.com/frappe/bench). [Start development](development).

# Production

We provide simple and intuitive production setup with prebuilt Frappe and ERPNext images and compose files. To learn more about those, [read the docs](docs/images-and-compose-files.md).

Also, there's docs to help with deployment:

- Examples:
  - [Single Server](docs/single-server-example.md)
  - [Setup options](docs/setup-options.md)
  - [Kubernetes (frappe/helm)](https://helm.erpnext.com)
- [Site operations](docs/site-operations.md).
- Other
  - [backup and push cron jobs](docs/backup-and-push-cronjob.md)
  - [bench console and vscode debugger](docs/bench-console-and-vscode-debugger.md)
  - [build version 10](docs/build-version-10-images.md)
  - [connect to localhost services from containers for local app development](docs/connect-to-localhost-services-from-containers-for-local-app-development.md)
  - [patch code from images](docs/patch-code-from-images.md)
  - [port based multi tenancy](docs/port-based-multi-tenancy.md)
- [Troubleshoot](docs/troubleshoot.md)

# Custom app

Learn how to containerize your custom Frappe app(s) in [this guide](custom_app/README.md).

# Contributing

If you want to contribute to this repo refer to [CONTRIBUTING.md](CONTRIBUTING.md)

This repository is only for Docker related stuff. You also might want to contribute to:

- [Frappe framework](https://github.com/frappe/frappe#contributing),
- [ERPNext](https://github.com/frappe/erpnext#contributing),
- or [Frappe Bench](https://github.com/frappe/bench).
