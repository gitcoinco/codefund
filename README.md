# CodeFund

[![All Contributors](https://img.shields.io/badge/all_contributors-8-orange.svg?style=flat-square)](#contributors)
[![Build Status](https://travis-ci.org/gitcoinco/codefund.svg?branch=master)](https://travis-ci.org/codesponsor/web)
[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://github.com/prettier/prettier)

CodeFund is an sponsorship platform to help fund open source projects and developers. Learn more at [https://codefund.io](https://codefund.io/t/s/76674f2b-a37b-4bf7-8e20-25d3913f0012/)

<img src="https://codefund.io/t/p/76674f2b-a37b-4bf7-8e20-25d3913f0012/pixel.png" width="1" height="1" style="width: 1px; height: 1px;" />

Here are a few blog posts and podcasts that discuss CodeFund:

- [Fighting for Open Source Sustainability: Introducing Code Sponsor](https://medium.com/code-sponsor/fighting-for-open-source-sustainability-introducing-code-sponsor-577e0ccca025)
- [Why Funding Open Source is Hard](https://medium.com/@codesponsor/why-funding-open-source-is-hard-652b7055569d)
- [Code Sponsor + Gitcoin = OSS Sustainability](https://medium.com/gitcoin/code-sponsor-gitcoin-oss-sustainability-5684c4adf4b4)
- [Sustaining Open Source](https://startupcto.io/podcast/0-57-sustaining-open-source-w-eric-berry-codesponsor-io/)
- [Sustaining Open-Source Software through Ethical Advertising](https://devchat.tv/js-jabber/jsj-281-codesponsor-sustaining-open-source-software-ethical-advertising-eric-berry)

# Table of Contents

- [What is this?](#what-is-this)
- [Why is it open source?](#why-is-it-open-source)
- [Development](#development)
- [Road map](#road-map)
- [Code of Conduct](#code-of-conduct)
- [Contributors](#contributors)

## What is this?

This is the software behind [codefund.io](https://codefund.io/t/s/76674f2b-a37b-4bf7-8e20-25d3913f0012/). It's an [Elixir](http://elixir-lang.org) application built on the [Phoenix](http://www.phoenixframework.org) web framework, [PostgreSQL](https://www.postgresql.org), and [many](https://github.com/gitcoinco/codefund/blob/master/mix.exs#L42) [other](https://github.com/gitcoinco/codefund/blob/master/assets/package.json) great open source efforts.

## Why is it open source?

We have built our careers on open source. We all owe a great debt to all open source developers who
given so much of their free time and talents to help others. We were also inspired by [The Changelog](https://github.com/thechangelog/changelog.com),
who released their platform open source. Finally, we want to be a trusted partner to the developer
community. To us, ad networks have always felt a bit shady. By being open source, we invite all to
critique our code and ensure we are being honest.

## Development

#### Using Docker

1.  Setup a complete docker and docker-compose installation
1.  Clone this repository
1.  Copy `.env-sample` to `.env`
1.  Built the phoenix app into image: `docker-compose build`
1.  Install dependencies: `docker-compose run web mix deps.get`
1.  Create the database: `docker-compose run web mix ecto.create`
1.  Run the migrations: `docker-compose run web mix ecto.migrate`
1.  Seed the db: `docker-compose run web mix code_fund.seed`
1.  Run the services: `docker-compose up -d`
1.  Visit [localhost:4000](http://localhost:4000) to see CodeFund running.

#### Without Docker (native setup)

Here are some basic steps to get CodeFund running:

```shell
git clone git@github.com:gitcoinco/codefund.git
cd codefund/
# Optionally set the following environment variables (see .env-sample)
# config postgres in config/dev.exs
# start postgres
gem install fakes3

mix deps.get
mix ecto.create
mix ecto.migrate
mix code_fund.seed
cd assets && npm install
cd ../
mix maxmind.setup
fakes3 -r /tmp/fakes3_root -p 4567
mix phx.server
```

#### Running Tests
We use `fakes3` for mocking S3 uploads so you will need to have this service running prior to running tests.
You can run this and tests automatically with `./bin/run_tests`

#### What To Consider On Your Pull Requests

1.  Please run `mix format` prior to submitting a pull request.
2.  We're working on adding typespec to the codebase. Please consider adding them to your pull requests so we can move ahead quicker.
3.  Please make sure you've added, changed or removed tests accordingly for the code you've modified.
4.  Consider running `mix credo list --ignore readability,design,refactor` to make sure your code is consistent and styled well.
5.  Have fun!

## Road map

We have a road map of what we are going to implement next.

[CodeFund Q1 Goals](https://github.com/gitcoinco/codefund/issues/1)

If you wish to add features that are not on the road map, you're very welcome to do so. We encourage you to
[create an Issue](https://github.com/gitcoinco/codefund/issues/new)
before coding, so we can all discuss the relevance to the community.

Please keep in mind that the focus is to create a great platform, so we might not implement/accept all the suggested features.

## Code of Conduct

[Contributor Code of Conduct](https://github.com/gitcoinco/codefund/blob/master/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## Attributions

This product includes GeoLite data created by MaxMind, available from [http://www.maxmind.com](http://www.maxmind.com).

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore -->
| [<img src="https://avatars2.githubusercontent.com/u/12481?v=4" width="100px;"/><br /><sub><b>Eric Berry</b></sub>](https://codefund.io)<br />[💻](https://github.com/codesponsor/web/commits?author=coderberry "Code") [📖](https://github.com/codesponsor/web/commits?author=coderberry "Documentation") [📦](#platform-coderberry "Packaging/porting to new platform") | [<img src="https://avatars1.githubusercontent.com/u/660973?v=4" width="100px;"/><br /><sub><b>Miguel Angel Gordián</b></sub>](http://zoek1.github.com)<br />[💻](https://github.com/codesponsor/web/commits?author=zoek1 "Code") [📖](https://github.com/codesponsor/web/commits?author=zoek1 "Documentation") [🚇](#infra-zoek1 "Infrastructure (Hosting, Build-Tools, etc)") [📦](#platform-zoek1 "Packaging/porting to new platform") | [<img src="https://avatars3.githubusercontent.com/u/1427179?v=4" width="100px;"/><br /><sub><b>Justin Bean</b></sub>](http://stareintothebeard.github.io/)<br />[💻](https://github.com/codesponsor/web/commits?author=StareIntoTheBeard "Code") [📖](https://github.com/codesponsor/web/commits?author=StareIntoTheBeard "Documentation") [🤔](#ideas-StareIntoTheBeard "Ideas, Planning, & Feedback") [⚠️](https://github.com/codesponsor/web/commits?author=StareIntoTheBeard "Tests") | [<img src="https://avatars1.githubusercontent.com/u/4920000?v=4" width="100px;"/><br /><sub><b>bakaoh</b></sub>](https://github.com/bakaoh)<br />[💻](https://github.com/codesponsor/web/commits?author=bakaoh "Code") [📖](https://github.com/codesponsor/web/commits?author=bakaoh "Documentation") | [<img src="https://avatars0.githubusercontent.com/u/3855429?v=4" width="100px;"/><br /><sub><b>Samuel Volin</b></sub>](http://untra.io)<br />[💻](https://github.com/codesponsor/web/commits?author=untra "Code") [🚇](#infra-untra "Infrastructure (Hosting, Build-Tools, etc)") [🔧](#tool-untra "Tools") | [<img src="https://avatars2.githubusercontent.com/u/6059356?v=4" width="100px;"/><br /><sub><b>Limon Monte</b></sub>](https://limonte.github.io)<br />[🐛](https://github.com/codesponsor/web/issues?q=author%3Alimonte "Bug reports") [💻](https://github.com/codesponsor/web/commits?author=limonte "Code") | [<img src="https://avatars2.githubusercontent.com/u/7039523?v=4" width="100px;"/><br /><sub><b>Arun Kumar</b></sub>](https://github.com/arun1595)<br />[💻](https://github.com/codesponsor/web/commits?author=arun1595 "Code") [📖](https://github.com/codesponsor/web/commits?author=arun1595 "Documentation") |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| [<img src="https://avatars1.githubusercontent.com/u/2035357?v=4" width="100px;"/><br /><sub><b>Ivan Tivonenko</b></sub>](https://github.com/darkdarkdragon)<br />[💻](https://github.com/codesponsor/web/commits?author=darkdarkdragon "Code") [⚠️](https://github.com/codesponsor/web/commits?author=darkdarkdragon "Tests") |

<!-- ALL-CONTRIBUTORS-LIST:END -->
