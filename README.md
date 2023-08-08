# creativecommons.org-environment

Local development environment for creativecommons.org


## Docker containers

The [`docker-compose.yml`](docker-comose.yml) file defines the following
containers:

1. cc-web ([localhost:8080](http://localhost:8080/))
2. cc-wordpress-db
3. cc-composer
4. cc-phpmyadmin ([localhost:8003](http://localhost:8003/))
5. cc-wpcli


## Setup

1. Ensure the following repositories are cloned adjancent to this repository:
    ```
    PARENT_DIR
    ├── cc-legal-tools-data
    ├── creativecommons.org-environment
    ├── chooser
    ├── faq
    └── mp
    ```
   - [creativecommons/cc-legal-tools-data][gh-cc-legal-tools-data]
   - [creativecommons/chooser][chooser]
   - [creativecommons/faq][faq]
   - [creativecommons/mp][mp]
1. Create the `.env` file:
    ```shell
    cp .env.example .env
    ```
2. Update `.env` to set desired values for variables (`WP_VERSION`,
   `WP_MOD_TYPE`, `WP_MOD_NAME`, etc.)
3. Build/start Docker:
    ```shell
    docker compose up
    ```
4. Wait for build and initialization to complete
5. Install WordPress initially through the GUI.
   - **TODO:** Script help here

[gh-cc-legal-tools-data]: https://github.com/creativecommons/cc-legal-tools-data
[chooser]: https://github.com/creativecommons/chooser
[faq]: https://github.com/creativecommons/faq
[mp]: https://github.com/creativecommons/mp


## Plugins

| name | version |
| --- | --- |
| [Advanced Custom Fields](https://wordpress.org/plugins/advanced-custom-fields/) | ^1.6 |
| [Advanced Custom Fields: Menu Chooser](https://github.com/reyhoun/acf-menu-chooser) | v1.1.0 |
| [Classic Editor](https://wordpress.org/plugins/classic-editor/) | ^6.1 |
