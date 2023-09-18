# index-dev-env

Local development environment for CreativeCommons.org.

`index` is the product name for the CreativeCommons.org website.


## Overview

This repository has the configuration required to run the CreativeCommons.org
website in a local Docker development environment.

The CreativeCommons.org website is comprised of five components that are split
into two categories:
- dynamic component:
  - WordPress
- static components:
  - Chooser
  - FAQ
  - Legal Tools (licenses and public domain dedications)
  - Platform Toolkit


## Code of Conduct

[`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md):
> The Creative Commons team is committed to fostering a welcoming community.
> This project and all other Creative Commons open source projects are governed
> by our [Code of Conduct][code_of_conduct]. Please report unacceptable
> behavior to [conduct@creativecommons.org](mailto:conduct@creativecommons.org)
> per our [reporting guidelines][reporting_guide].

[code_of_conduct]: https://opensource.creativecommons.org/community/code-of-conduct/
[reporting_guide]: https://opensource.creativecommons.org/community/code-of-conduct/enforcement/


## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).


## Docker containers

The [`docker-compose.yml`](docker-comose.yml) file defines the following
containers:
1. **index-composer** - A Dependency Manager for PHP
   - This container does not have a persistent service. Expect the following
     message when you start the services: `index-composer exited with code 0`
2. **index-phpmyadmin** - Database administration
   - [localhost:8003](http://localhost:8003/)
3. **index-wpcli** - The command line interface for WordPress
   - This container does not have a persistent service. Expect the following
     message when you start the services: `index-wpcli exited with code 0`
4. **index-web** - Web server (WordPress and static HTML components)
   - **[localhost:8080](http://localhost:8080/)**
5. **index-wpdb** - Database server for WordPress


## Setup

1. Ensure the following repositories are cloned adjacent to this repository:
    ```
    PARENT_DIR
    ├── cc-legal-tools-data
    ├── chooser
    ├── dev-index-env
    ├── faq
    └── mp
    ```
   - [creativecommons/cc-legal-tools-data][gh-cc-legal-tools-data]
   - [creativecommons/chooser][gh-chooser]
   - [creativecommons/faq][gh-faq]
   - [creativecommons/mp][gh-mp]
2. Create the `.env` file:
    ```shell
    cp .env.example .env
    ```
3. Update `.env` to set desired values for variables (`WP_VERSION`,
   `WP_MOD_TYPE`, `WP_MOD_NAME`, etc.)
4. Build/start Docker:
    ```shell
    docker compose up
    ```
5. Wait for build and initialization to complete
6. Setup WordPress:
    ```shell
    ./setup-wordpress.sh
    ```
7. Optionally: manually activate/configure `wordfence` in the GUI for now.
    - **TODO:** Script help here

[gh-cc-legal-tools-data]: https://github.com/creativecommons/cc-legal-tools-data
[gh-chooser]: https://github.com/creativecommons/chooser
[gh-faq]: https://github.com/creativecommons/faq
[gh-mp]: https://github.com/creativecommons/mp


## Dev component URLs

| Dev Component          | Dev path routing              |
| ---------------------- | ----------------------------- |
| _dev_ Chooser          | [`/choose`][dev-choose]       |
| _dev_ FAQ              | [`/faq`][dev-faq]             |
| _dev_ Licenses         | [`/licenses`][dev-licenses]   |
| _dev_ Platform Toolkit | [`/platform/toolkit`][dev-mp] |
| _dev_ Public Domain    | [`/publicdomain`][dev-public] |
| **_dev_ WordPress**    | **[`/` (default)][dev-wp]**   |
| _dev_ WordPress Admin  | [`/wp-admin/`][dev-wp-admin]  |

Also see [`config/web-sites-available/000-default.conf`][dev-webconfig].

[dev-choose]: http://localhost:8080/choose
[dev-faq]: http://localhost:8080/faq
[dev-licenses]: http://localhost:8080/licenses
[dev-mp]: http://localhost:8080/platform/toolkit
[dev-public]: http://localhost:8080/publicdomain
[dev-wp]: http://localhost:8080/
[dev-wp-admin]: http://localhost:8080/wp-admin/
[dev-webconfig]: config/web-sites-available/000-default.conf


## Stage component URLs

Please note that the staging environment is password protected.

| Stage Component        | Stage path routing              |
| ---------------------- | ------------------------------- |
| _stage_ Chooser          | [`/choose`][stage-choose]       |
| _stage_ FAQ              | [`/faq`][stage-faq]             |
| _stage_ Licenses         | [`/licenses`][stage-licenses]   |
| _stage_ Platform Toolkit | [`/platform/toolkit`][stage-mp] |
| _stage_ Public Domain    | [`/publicdomain`][stage-public] |
| **_stage_ WordPress**    | **[`/` (default)][stage-wp]**   |
| _stage_ WordPress Admin  | [`/wp-admin/`][stage-wp-admin]  |

Also see [Stage Salt configurations](#stage-salt-configurations), below.

[stage-choose]: http://stage.creativecommons.org/choose
[stage-faq]: http://stage.creativecommons.org/faq
[stage-licenses]: http://stage.creativecommons.org/licenses
[stage-mp]: http://stage.creativecommons.org/platform/toolkit
[stage-public]: http://stage.creativecommons.org/publicdomain
[stage-wp]: http://stage.creativecommons.org/
[stage-wp-admin]: http://stage.creativecommons.org/wp-admin/
[stage-webconfig]: config/web-sites-available/000-default.conf


## Dev WordPress versions


### Core

| Name      | Version |
| --------- | ------- |
| WordPress | `6.3`   |

Also see [`.env.example`](.env.example).


### Plugins

| Name                                                     | Version  |
| -------------------------------------------------------- | -------- |
| [Advanced Custom Fields][adv-custom-fields]              | `6.1.8`  |
| [Advanced Custom Fields: Menu Chooser][acf-menu-chooser] | `1.1.0`  |
| [Classic Editor][classic-editor]                         | `1.6.3`  |
| [Redirection][redirection]                               | `4.9.2`  |
| [Tablepress][tablepress]                                 | `1.14`   |
| [Wordfence][wordfence]                                   | `7.10.3` |
| [WordPress Imorter][wp-importer]                         | `0.8.1`  |

Also see [`config/composer/composer.json`](config/composer/composer.json).

[adv-custom-fields]: https://wordpress.org/plugins/advanced-custom-fields/
[acf-menu-chooser]: https://github.com/reyhoun/acf-menu-chooser
[classic-editor]: https://wordpress.org/plugins/classic-editor/
[redirection]: https://wordpress.org/plugins/redirection/
[tablepress]: https://wordpress.org/plugins/tablepress/
[wordfence]: https://wordpress.org/plugins/wordfence/
[wp-importer]: https://wordpress.org/plugins/wordpress-importer/


### Themes

| Name                                 | Version |
| ------------------------------------ | ------- |
| [Vocabulary Theme][vocabulary-theme] | `0.11.0` |

Also see [`config/composer/composer.json`](config/composer/composer.json).

[vocabulary-theme]: https://github.com/creativecommons/vocabulary-theme


## Stage Salt configurations

The staging server is configured via Salt managed in the in
[creativecommons/sre-salt-prime][sre-salt-prime] repository. The list below
include the specifics (is non-exhaustive):
- `pillars/`
  - [`3_HST/index/`][salt-hst-index]
  - [`5_HST__POD/index__stage`][salt-hst-pod-index]
- `states/`
  - [`apache2/files/creativecommons_org.conf`][salt-index-conf]
  - [`wordpress/files/index-composer.json`][salt-index-composer]
  - [`wordpress/index.sls`][salt-wordpress-index]

[sre-salt-prime]: https://github.com/creativecommons/sre-salt-prime
[salt-hst-index]: https://github.com/creativecommons/sre-salt-prime/tree/main/pillars/3_HST/index
[salt-hst-pod-index]: https://github.com/creativecommons/sre-salt-prime/tree/main/pillars/5_HST__POD/index__stage
[salt-index-conf]: https://github.com/creativecommons/sre-salt-prime/blob/main/states/apache2/files/creativecommons_org.conf
[salt-index-composer]: https://github.com/creativecommons/sre-salt-prime/blob/main/states/wordpress/files/index-composer.json
[salt-wordpress-index]: https://github.com/creativecommons/sre-salt-prime/blob/main/states/wordpress/index.sls


## Copying

[![CC0 1.0 Universal (CC0 1.0) Public Domain Dedication
button][cc-zero-png]][cc-zero]

[`COPYING`](COPYING): All the content within this repository is dedicated to
the public domain under the [CC0 1.0 Universal (CC0 1.0) Public Domain
Dedication][cc-zero].

[cc-zero-png]: https://licensebuttons.net/l/zero/1.0/88x31.png "CC0 1.0 Universal (CC0 1.0) Public Domain Dedication button"
[cc-zero]: https://creativecommons.org/publicdomain/zero/1.0/ "Creative Commons — CC0 1.0 Universal"
