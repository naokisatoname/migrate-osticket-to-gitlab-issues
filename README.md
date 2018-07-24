# migrate-osticket-to-gitlab-issues

Migrate osTicket tickets and tasks to GitLab as Issues in a specific project.

## Usage

```bash
$ bundle install --path vendor/bundle
$ bundle exec ruby migrate.rb
```

## Prerequisite

Before you run the script:

* `config/config.yml` needs to be created for your envirnment.
* `assets/sql/create-views.sql` needs to be run on osTicket MySQL database, to create some views.

## Note

Tested on:

- osTicket : 1.10
- MySQL : 5.7
- Gems
    - gitlab : 4.4.0
    - mysql2 : 0.5.2

