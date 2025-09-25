## Installation guide

Get the latest `surveilr` by following these steps to complete the installation:

1. Visit our GitHub Releases page:

   - Navigate to our [GitHub Releases](https://github.com/opsfolio/releases.opsfolio.com/releases) page to download the latest version of `surveilr` that’s compatible with your operating system.

2. Download the appropriate version:

   - Select and download the version that matches your operating system (Windows, macOS, or Linux).

3. Using Scripts

   - **Windows:**

      ```powershell
         $ irm https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/refs/heads/main/surveilr/install.ps1 | iex
      ```

   - **macOS and Linux:**
        Install in desired path by running any of the following commands:

        ```bash
        # install in current path
        $ curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | bash

        # Install globally
        $ curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | SURVEILR_HOME="$HOME/bin" bash

        # install in preferred path
        $ curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | SURVEILR_HOME="/path/to/directory" bash
        ```
4. Run verification steps [here](#verify-installation).

### Alternative Installation for Linux Using Eget

1. Before you can get anything, you have to get [Eget](https://github.com/zyedidia/eget):

   ```bash
   $ curl https://zyedidia.github.io/eget.sh | sh
   ```

2. Now install `surveilr` using `eget`:

   ```bash
   $ eget opsfolio/releases.opsfolio.com --asset tar.gz
   ```

3. Run verification steps [here](#verify-installation).

## Verify installation

Run the following command to verify that `surveilr` is installed correctly:

```bash
$ surveilr --version                      # version information
$ surveilr doctor                         # dependencies that surveilr uses
$ surveilr --help                         # get CLI help (pay special attention to ENV var names)
```

Checkout more commands in the [reference section](https://docs.opsfolio.com/surveilr/reference/cli/commands/)

## Upgrading `surveilr`

The following commands shows how to upgrade `surveilr` on your:

```bash
$ surveilr upgrade ## Upgrades to the latest version

$ surveilr upgrade -v 0.13.0 ## Upgrades to version 0.13.0 if present
```

When using the command above, you will be prompted to confirm the upgrade by typing `yes`. However, if you are running the upgrade in a bash script, you won't be able to provide this confirmation interactively. To address this, we have provided the `--yes` or `--y` flag, which automatically skips the confirmation step. Here is how to use it:

```bash
## Upgrades to the latest version and skips confirmation
$ surveilr upgrade --yes

## Upgrades to version 0.1.2 if present and  skips the confirmation
$ surveilr upgrade -v 0.13.0 --yes
```

## Downgrading `surveilr`

The following commands shows how to downgrade `surveilr` to any version:

```bash
$ surveilr upgrade -v 0.12.0 ## downgrades to version 0.12.0
```
This takes the same form as the `upgrade` command with the only difference being that a lower version is passed.

<!-- Security scan triggered at 2025-09-02 15:49:15 -->
