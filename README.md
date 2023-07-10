# creativecommons.org-environment

WordPress implementation of creativecommons.org

(May expand into sibling apps, likely not)


## Docker containers

The [`docker-compose.yml`](docker-comose.yml) file defines the following
containers:

1. cc-wordpress-web ([localhost:8080](http://localhost:8080/))
2. cc-wordpress-db
3. cc-composer
4. cc-phpmyadmin ([localhost:8003](http://localhost:8003/))
5. cc-wpcli


## Setup

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
5. Install WordPress initially through the GUI. (TODO: Script help here)


## Plugins 
| name | version |
| --- | --- |
| [Advanced Custom Fields](https://wordpress.org/plugins/advanced-custom-fields/) | ^1.6 |
| [Advanced Custom Fields: Menu Chooser](https://github.com/reyhoun/acf-menu-chooser) | v1.1.0 |
| [Classic Editor](https://wordpress.org/plugins/classic-editor/) | ^6.1 |
