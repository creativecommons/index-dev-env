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
   - [creativecommons/chooser][gh-chooser]
   - [creativecommons/faq][gh-faq]
   - [creativecommons/mp][gh-mp]
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
[gh-chooser]: https://github.com/creativecommons/chooser
[gh-faq]: https://github.com/creativecommons/faq
[gh-mp]: https://github.com/creativecommons/mp


## Dev component URLs

| Component        | URL                           |
| ---------------- | ----------------------------- |
| Chooser          | [`/choose`][dev-choose]       |
| FAQ              | [`/faq`][dev-faq]             |
| Licenses         | [`/licenses`][dev-licenses]   |
| Platform Toolkit | [`/platform/toolkit`][dev-mp] |
| Public Domain    | [`/publicdomain`][dev-public] |
| WordPress        | [`/` (default)][dev-wp]       |

[dev-choose]: http://localhost:8080/choose
[dev-faq]: http://localhost:8080/faq
[dev-licenses]: http://localhost:8080/licenses
[dev-mp]: http://localhost:8080/platform/toolkit
[dev-public]: http://localhost:8080/publicdomain
[dev-wp]: http://localhost:8080/


## Plugins

| Name                                                     | Version  |
| -------------------------------------------------------- | -------- |
| [Advanced Custom Fields][adv-custom-fields]              | `6.1`   |
| [Advanced Custom Fields: Menu Chooser][acf-menu-chooser] | `1.1.0` |
| [Classic Editor][classic-editor]                         | `1.6`   |
| [Redirection][redirection]                               | `4.8` |
| [Tablepress][tablepress]                                 | `1.12` |
| [Wordfence][wordfence]                                   | `7.10.3` |


[adv-custom-fields]: https://wordpress.org/plugins/advanced-custom-fields/
[acf-menu-chooser]: https://github.com/reyhoun/acf-menu-chooser
[classic-editor]: https://wordpress.org/plugins/classic-editor/
[redirection]: https://wordpress.org/plugins/redirection/
[tablepress]: https://wordpress.org/plugins/tablepress/
[wordfence]: https://wordpress.org/plugins/wordfence/


## Themes

| Name                                                     | Version  |
| -------------------------------------------------------- | -------- |
| [Vocabulary Theme][vocabulary-theme]                     | `0.1.0`  |


[vocabulary-theme]: https://github.com/creativecommons/vocabulary-theme