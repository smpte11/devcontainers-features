# Dev Container Features

This repository contains a collection of [dev container Features](https://containers.dev/implementors/features/).

## Features

### [Coursier](https://get-coursier.io/) (`coursier`)

The `coursier` feature installs [coursier](https://get-coursier.io/), the Scala application and artifact manager, along with other essential Scala tools in your development container.

For more details, see the [coursier feature README](./src/coursier/README.md).

## Repository Structure

This repository follows the conventional structure for dev container feature collections. Each feature is organized in its own subdirectory within the `src` folder, which includes at least a `devcontainer-feature.json` file and an `install.sh` script.

```
.
├── src
│   └── coursier
│       ├── devcontainer-feature.json
│       └── install.sh
└── ...
```

## Distribution

The features in this repository are published to the GitHub Container Registry (GHCR). A [GitHub Action workflow](./.github/workflows/release.yaml) is configured to automate the publishing process.

Each feature is identified by a namespace constructed from the owner and repository, such as:

```
ghcr.io/smpte11/devcontainers-features/coursier:1
```

For detailed information on publishing and distributing features, refer to the [official documentation](https://containers.dev/implementors/features-distribution/).
