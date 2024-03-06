# index-dev-env

Local development environment for CreativeCommons.org (product name: `index`).


## Overview

This repository has the configuration required to run the CreativeCommons.org
website in a local Docker development environment.

The CreativeCommons.org website is comprised of five components that are split
into two categories:
- dynamic component:
  - WordPress (Vocabulary Theme)
- static components:
  - Chooser
  - FAQ
  - Legal Tools (licenses and public domain)
  - Platform Toolkit


### Component repositories

Path label|Path|Component name|Component repositories
----------|----|--------------|----------------------
Chooser|`/choose`|Chooser|[chooser][gh-chooser]
FAQ|`/faq`|FAQ|[faq][gh-faq]
Licenses| `/licenses`|CC Legal Tools|[cc-legal-tools-app][gh-app], [cc-legal-tools-data][gh-data]
Platform Toolkit|`/platform/toolkit`|Platform Toolkit|[mp][gh-mp]
Public Domain|`/publicdomain`|CC Legal Tools|[cc-legal-tools-app][gh-app], [cc-legal-tools-data][gh-data]
WordPress|`/` (default)|Vocabulary Theme|[vocabulary-theme][gh-vocab-theme]

[gh-chooser]: https://github.com/creativecommons/chooser
[gh-faq]: https://github.com/creativecommons/faq
[gh-app]: https://github.com/creativecommons/cc-legal-tools-app
[gh-data]: https://github.com/creativecommons/cc-legal-tools-data
[gh-mp]: https://github.com/creativecommons/mp
[gh-vocab-theme]: https://github.com/creativecommons/vocabulary-theme


## Code of conduct

[`CODE_OF_CONDUCT.md`][org-coc]:
> The Creative Commons team is committed to fostering a welcoming community.
> This project and all other Creative Commons open source projects are governed
> by our [Code of Conduct][code_of_conduct]. Please report unacceptable
> behavior to [conduct@creativecommons.org](mailto:conduct@creativecommons.org)
> per our [reporting guidelines][reporting_guide].

[org-coc]: https://github.com/creativecommons/.github/blob/main/CODE_OF_CONDUCT.md
[code_of_conduct]: https://opensource.creativecommons.org/community/code-of-conduct/
[reporting_guide]: https://opensource.creativecommons.org/community/code-of-conduct/enforcement/


## Contributing

See [`CONTRIBUTING.md`][org-contrib].

[org-contrib]: https://github.com/creativecommons/.github/blob/main/CONTRIBUTING.md


## Docker containers

The [`docker-compose.yml`](docker-comose.yml) file defines the following
containers:
1. **index-web** - Web server (WordPress and static HTML components)
   - **[localhost:8080](http://localhost:8080/)**
2. **index-db** - Database server for WordPress


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
   - [creativecommons/cc-legal-tools-data][gh-data]
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
7. _Optional (CC staff only):_ import production data
   1. Ensure you have access to the production server and your local machine
      is properly configured to access it
   2. Pull production data
        ```shell
        ./staff_migrate.sh pull
        ```
   3. Import production data
        ```shell
        ./staff_migrate.sh import
        ```


## Path URLs

Path label|Dev link|Stage link|Prod link
----------|--------|----------|---------
Chooser|[Dev `/choose`][d1]|[Stage `/choose`][s1]|[Prod `/choose`][p1]
FAQ|[Dev `/faq`][d2]|[Stage `/faq`][s2]|[Prod `/faq`][p2]
Licenses|[Dev `/licenses`][d3]|[Stage `/licenses`][s3]|[Prod `/licenses`][p3]
Platform Toolkit|[Dev `/platform/toolkit`][d4]|[Stage `/platform/toolkit`][s4]|[Prod `/platform/toolkit`][p4]
Public Domain|[Dev `/publicdomain`][d5]|[Stage `/publicdomain`][s5]|[Prod `/publicdomain`][p5]
WordPress|[Dev `/` (default)][d6]|[Stage `/` (default)][s6]|[Prod `/` (default)][p6]
WordPress Admin|[Dev `/wp-admin`][d7]|[Stage `/wp-admin`][s7]|[Prod `/wp-admin`][p7]

[d1]: http://localhost:8080/choose "Dev Chooser /choose"
[d2]: http://localhost:8080/faq "Dev FAQ /faq"
[d3]: http://localhost:8080/licenses "Dev Licenses /licenses"
[d4]: http://localhost:8080/platform/toolkit "Dev Platform Toolkit /platform/toolkit"
[d5]: http://localhost:8080/publicdomain "Dev Public Domain /publicdomain"
[d6]: http://localhost:8080/ "Dev WordPress / (default)"
[d7]: http://localhost:8080/wp-admin/ "Dev WordPress Admin /wp-admin"

[s1]: https://stage.creativecommons.org/choose "Stage Chooser /choose"
[s2]: https://stage.creativecommons.org/faq "Stage FAQ /faq"
[s3]: https://stage.creativecommons.org/licenses "Stage Licenses /licenses"
[s4]: https://stage.creativecommons.org/platform/toolkit "Stage Platform Toolkit /platform/toolkit"
[s5]: https://stage.creativecommons.org/publicdomain "Stage Public Domain /publicdomain"
[s6]: https://stage.creativecommons.org/ "Stage WordPress / (default)"
[s7]: https://stage.creativecommons.org/wp-admin/ "Stage WordPress Admin /wp-admin"

[p1]: https://creativecommons.org/choose "Prod Chooser /choose"
[p2]: https://creativecommons.org/faq "Prod FAQ /faq"
[p3]: https://creativecommons.org/licenses "Prod Licenses /licenses"
[p4]: https://creativecommons.org/platform/toolkit "Prod Platform Toolkit /platform/toolkit"
[p5]: https://creativecommons.org/publicdomain "Prod Public Domain /publicdomain"
[p6]: https://creativecommons.org/ "Prod WordPress / (default)"
[p7]: https://creativecommons.org/wp-admin/ "Prod WordPress Admin /wp-admin"


## Dev configuration


### Apache2

See [`config/web-sites-available/000-default.conf`][dev-webconfig].

[dev-webconfig]: config/web-sites-available/000-default.conf


### WordPress core

| Name      | Version |
| --------- | ------- |
| WordPress | `6.4.3`   |

Also see [`.env.example`](.env.example).


### WordPress plugins

| Name                                                     | Version  |
| -------------------------------------------------------- | -------- |
| [Advanced Custom Fields][adv-custom-fields]              | `6.2.7`  |
| [Advanced Custom Fields: Menu Chooser][acf-menu-chooser] | `1.1.0`  |
| [Classic Editor][classic-editor]                         | `1.6.3`  |
| [Monster Insights Google Analytics][monster-insights]    | `8.19`   |
| [Redirection][redirection]                               | `5.3.10` |
| [Tablepress][tablepress]                                 | `2.1.7`  |
| [Wordfence][wordfence]                                   | `7.10.4` |
| [WordPress Importer][wp-importer]                        | `0.8.1`  |
| [Yoast SEO][yoast-seo]                                   | `21.2`   |

Also see [`config/composer/composer.json`](config/composer/composer.json).

[adv-custom-fields]: https://wordpress.org/plugins/advanced-custom-fields/
[acf-menu-chooser]: https://github.com/reyhoun/acf-menu-chooser
[classic-editor]: https://wordpress.org/plugins/classic-editor/
[monster-insights]: https://wordpress.org/plugins/google-analytics-for-wordpress/
[redirection]: https://wordpress.org/plugins/redirection/
[tablepress]: https://wordpress.org/plugins/tablepress/
[wordfence]: https://wordpress.org/plugins/wordfence/
[wp-importer]: https://wordpress.org/plugins/wordpress-importer/
[yoast-seo]: https://wordpress.org/plugins/wordpress-seo/


### WordPress themes

| Name                                 | Version  |
| ------------------------------------ | -------- |
| [Vocabulary Theme][gh-vocab-theme]   | `1.3.2`    |

Also see [`config/composer/composer.json`](config/composer/composer.json).


## Stage and Prod configuration

The staging server and production server are configured via Salt managed in the
[creativecommons/sre-salt-prime][sre-salt-prime] repository. The list below
include the specifics (is non-exhaustive):
- `pillars/`
  - [`3_HST/index/`][salt-hst-index]
  - [`5_HST__POD/index__stage`][salt-hst-pod-index]
- `states/`
  - [`apache2/files/index.conf`][salt-index-conf]
  - [`wordpress/files/index-composer.json`][salt-index-composer]
  - [`wordpress/index.sls`][salt-wordpress-index]

[sre-salt-prime]: https://github.com/creativecommons/sre-salt-prime
[salt-hst-index]: https://github.com/creativecommons/sre-salt-prime/tree/main/pillars/3_HST/index
[salt-hst-pod-index]: https://github.com/creativecommons/sre-salt-prime/tree/main/pillars/5_HST__POD/index__stage
[salt-index-conf]: https://github.com/creativecommons/sre-salt-prime/blob/main/states/apache2/files/index.conf
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
