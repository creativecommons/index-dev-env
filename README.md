# index-dev-env

Local development environment for CreativeCommons.org (project name: `index`).


## Overview

This repository manages the local development environment for
CreativeCommons.org (project name: `index`). It relies on Docker and requires
the component repositories.


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


## Index components

The CreativeCommons.org website (project name: `index`) is comprised of five
components that are split into two categories:
1. Static components
  - CC Legal Tools ("licenses")
  - Chooser
  - FAQ
  - Platform Toolkit
2. Dynamic component
  - WordPress (Vocabulary Theme)


### Static component repositories

| Component name | Component repositories |
| -------------- | ---------------------- |
| CC Legal Tools | [cc-legal-tools-app][s1], [cc-legal-tools-data][s2] |
| Chooser | [chooser][s3] |
| FAQ | [faq][s4] |
| Platform Toolkit | [mp][s5] |

[s1]: https://github.com/creativecommons/cc-legal-tools-app
[s2]: https://github.com/creativecommons/cc-legal-tools-data
[s3]: https://github.com/creativecommons/chooser
[s4]: https://github.com/creativecommons/faq
[s5]: https://github.com/creativecommons/mp


### Static component URIs

The following URIs and their children/subpaths **mustn't** be used by
WordPress. They are reserved for the static components:
| Path | Component name |
| ---- | -------------- |
| `/cc-legal-tools` | CC Legal Tools |
| `/choose` | Chooser |
| `/chooser` | Chooser |
| `/faq` | FAQ |
| `/licence` | CC Legal Tools |
| `/licences` | CC Legal Tools |
| `/license` | CC Legal Tools |
| `/licenses` | CC Legal Tools |
| `/ns` | CC Legal Tools |
| `/ns.html` | CC Legal Tools |
| `/platform` | Platform Toolkit |
| `/rdf` | CC Legal Tools |
| `/schema.rdf` | CC Legal Tools |

These URIs are controlled by Apache2 configurations:
- Dev: [`config/web-sites-available/000-default.conf`][a2conf-dev]
- Prod: `sre-salt-prime`: [`states/apache2/files/index.conf`][a2conf-prod]
  - (Also see **Stage and Prod configuration**, below)
- shared: `cc-legal-tools-data`: [`config/language-redirects`][a2conf-shared]

[a2conf-dev]: config/web-sites-available/000-default.conf
[a2conf-prod]: https://github.com/creativecommons/sre-salt-prime/blob/main/states/apache2/files/index.conf
[a2conf-shared]: https://github.com/creativecommons/cc-legal-tools-data/blob/main/config/language-redirects


### Dynamic component repository

| Component name | Component repository |
| -------------- | -------------------- |
| WordPress      | [vocabulary-theme][d1] |

[d1]: https://github.com/creativecommons/vocabulary-theme


### Dynamic component URIs

WordPress is the default handler for URIs. WordPress handles all URIs *except*
the **Static component URIs**, listed above.


## Docker containers

The [`docker-compose.yml`](docker-compose.yml) file defines the following
containers:
1. **index-db** - Database server for WordPress
2. **index-phpmyadmin** - Database administration
   - [localhost:8003](http://localhost:8003/)
3. **index-web** - Web server (WordPress and static HTML components)
   - **[localhost:8080](http://localhost:8080/)**


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


## Environment URLs

| Path label | Dev link | Stage link | Prod link |
| ---------- | -------- | ---------- | --------- |
| Chooser | [Dev `/choose`][a1] | [Stage `/choose`][b1] | [Prod `/choose`][c1] |
| FAQ | [Dev `/faq`][a2] | [Stage `/faq`][b2] | [Prod `/faq`][c2] |
| Licenses | [Dev `/licenses`][a3] | [Stage `/licenses`][b3] | [Prod `/licenses`][c3] |
| Platform Toolkit | [Dev `/platform/toolkit`][a4] | [Stage `/platform/toolkit`][b4] | [Prod `/platform/toolkit`][c4] |
| Public Domain | [Dev `/publicdomain`][a5] | [Stage `/publicdomain`][b5] | [Prod `/publicdomain`][c5] |
| WordPress | [Dev `/` (default)][a6] | [Stage `/` (default)][b6] | [Prod `/` (default)][c6] |
| WordPress Admin | [Dev `/wp-admin`][a7] | [Stage `/wp-admin`][b7] | [Prod `/wp-admin`][c7] |

[a1]: http://localhost:8080/choose "Dev Chooser /choose"
[a2]: http://localhost:8080/faq "Dev FAQ /faq"
[a3]: http://localhost:8080/licenses "Dev Licenses /licenses"
[a4]: http://localhost:8080/platform/toolkit "Dev Platform Toolkit /platform/toolkit"
[a5]: http://localhost:8080/publicdomain "Dev Public Domain /publicdomain"
[a6]: http://localhost:8080/ "Dev WordPress / (default)"
[a7]: http://localhost:8080/wp-admin/ "Dev WordPress Admin /wp-admin"

[b1]: https://stage.creativecommons.org/choose "Stage Chooser /choose"
[b2]: https://stage.creativecommons.org/faq "Stage FAQ /faq"
[b3]: https://stage.creativecommons.org/licenses "Stage Licenses /licenses"
[b4]: https://stage.creativecommons.org/platform/toolkit "Stage Platform Toolkit /platform/toolkit"
[b5]: https://stage.creativecommons.org/publicdomain "Stage Public Domain /publicdomain"
[b6]: https://stage.creativecommons.org/ "Stage WordPress / (default)"
[b7]: https://stage.creativecommons.org/wp-admin/ "Stage WordPress Admin /wp-admin"

[c1]: https://creativecommons.org/choose "Prod Chooser /choose"
[c2]: https://creativecommons.org/faq "Prod FAQ /faq"
[c3]: https://creativecommons.org/licenses "Prod Licenses /licenses"
[c4]: https://creativecommons.org/platform/toolkit "Prod Platform Toolkit /platform/toolkit"
[c5]: https://creativecommons.org/publicdomain "Prod Public Domain /publicdomain"
[c6]: https://creativecommons.org/ "Prod WordPress / (default)"
[c7]: https://creativecommons.org/wp-admin/ "Prod WordPress Admin /wp-admin"


## Dev configuration


### Apache2

See [`config/web-sites-available/000-default.conf`][dev-webconfig].

[dev-webconfig]: config/web-sites-available/000-default.conf


### WordPress core

| Name      | Version |
| --------- | :-----: |
| WordPress | `6.3.1` |

Also see [`.env.example`](.env.example).


### WordPress plugins

| Name                                                     | Version  |
| -------------------------------------------------------- | :------: |
| [Advanced Custom Fields][adv-custom-fields]              | `6.2.1`  |
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
| ------------------------------------ | :------: |
| [Vocabulary Theme][gh-vocab-theme]   | `2.9`  |

Also see [`config/composer/composer.json`](config/composer/composer.json).


### vocabulary-theme QA Checklist

<details>
<summary>vocabulary-theme release testing QA checklist (click to expand)</summary>

1. run setup-wp script (again to make sure WP is current version)
2. be sure to clear/disable caches locally
3. review any new context/template/page
4. review pages:
   - [home-page](http://localhost:8080/)
   - [sub-page](http://localhost:8080/about)
   - [team-index](http://localhost:8080/mission/team)
   - [search-index](http://localhost:8080/?s)
   - [archive-page](http://localhost:8080/blog/archive)
   - [blog-index](http://localhost:8080/blog)
   - [blog-post](http://localhost:8080/2025/03/03/from-strategy-to-action-focus-areas-for-2025/)
   - [faq](http://localhost:8080/faq)
   - [mp](http://localhost:8080/platform/toolkit/)
   - [licenses list](http://localhost:8080/licenses)
   - [license deed | EN](http://localhost:8080/licenses/by/4.0/)
   - [license legal code | EN](http://localhost:8080/licenses/by/4.0/legalcode.en)
   - [license deed | AR](http://localhost:8080/licenses/by/4.0/deed.ar)
   - [license legal code | AR](http://localhost:8080/licenses/by/4.0/legalcode.ar)

</details>


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
