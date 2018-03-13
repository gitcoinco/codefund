# Code Sponsor
[![All Contributors](https://img.shields.io/badge/all_contributors-2-orange.svg?style=flat-square)](#contributors)
[![Build Status](https://travis-ci.org/codesponsor/web.svg?branch=master)](https://travis-ci.org/codesponsor/web)
[![Waffle.io - Columns and their card count](https://badge.waffle.io/codesponsor/web.svg?columns=all)](https://waffle.io/codesponsor/web)


Code Sponsor is an sponsorship platform to help fund open source projects and developers. Learn more at [https://codesponsor.io](https://codesponsor.io)

Here are a few blog posts and podcasts that discuss Code Sponsor:

* [Fighting for Open Source Sustainability: Introducing Code Sponsor](https://medium.com/code-sponsor/fighting-for-open-source-sustainability-introducing-code-sponsor-577e0ccca025)
* [Why Funding Open Source is Hard](https://medium.com/@codesponsor/why-funding-open-source-is-hard-652b7055569d)
* [Code Sponsor + Gitcoin = OSS Sustainability](https://medium.com/gitcoin/code-sponsor-gitcoin-oss-sustainability-5684c4adf4b4)
* [Sustaining Open Source](https://startupcto.io/podcast/0-57-sustaining-open-source-w-eric-berry-codesponsor-io/)
* [Sustaining Open-Source Software through Ethical Advertising](https://devchat.tv/js-jabber/jsj-281-codesponsor-sustaining-open-source-software-ethical-advertising-eric-berry)

# Table of Contents
- [What is this?](#what-is-this)
- [Why is it open source?](#why-is-it-open-source)
- [Install](#install)
- [Road map](#road-map)
- [Code of Conduct](#code-of-conduct)
- [Contributors](#contributors)

## What is this?

This is the software behind [codesponsor.io](https://codesponsor.io). It's an [Elixir](http://elixir-lang.org) application built on the [Phoenix](http://www.phoenixframework.org) web framework, [PostgreSQL](https://www.postgresql.org), and [many](https://github.com/codesponsor/web/blob/master/mix.exs#L42) [other](https://github.com/codesponsor/web/blob/master/assets/package.json) great open source efforts.

## Why is it open source?

A few reasons:

1. We _love_ open source. Our careers (and livelihoods) wouldn't be possible without open source. Keeping it closed just feels _wrong_.
2. Phoenix is really great, but it's young enough in its lifecycle that there aren't _too many_ in-production, open source sites for people to refer to as examples or inspiration. We want to throw our hat into that ring and hopefully others will follow.
3. We know open sourcing the platform will lead to good things from y'all (such as bug reports, feature requests, and pull requests).

## Development

#### Using Docker

1. Setup a complete docker and docker-compose installation
2. Clone this repository
3. Copy `.env-sample` to `.env`
4. Built the phoenix app into image: docker-compose build
5. Create the database: docker-compose run web mix ecto.create
6. Run the migrations: docker-compose run web mix ecto.migrate
7. Seed the db: docker-compose run web mix code_sponsor.seed
8. Run the services: docker-compose up -d
9. Visit [localhost:4000](http://localhost:4000) to see code sponsor running.

#### Without Docker (native setup)

Here are some basic stemps to get Code Sponsor running:

```shell
git clone git@github.com:codesponsor/web.git
cd web/
# Optionally set the following environment variables (see .env-sample)
# config postgres in config/dev.exs
# start postgres
mix deps.get
mix ecto.create
mix ecto.migrate
mix code_sponsor.seed
cd assets && npm install
cd ../
mix phx.server
```

## Road map

We have a road map of what we are going to implement next.

[Code Sponsor Q1 Goals](https://github.com/codesponsor/web/issues/1)

If you wish to add features that are not on the road map, you're very welcome to do so. We encourage you to
[create an Issue](https://github.com/codesponsor/web/issues/new)
before coding, so we can all discuss the relevance to the community.

Please keep in mind that the focus is to create a great platform, so we might not implement/accept all the suggested features.

## Code of Conduct

[Contributor Code of Conduct](https://github.com/codesponsor/web/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore -->
| [<img src="https://avatars2.githubusercontent.com/u/12481?v=4" width="100px;"/><br /><sub><b>Eric Berry</b></sub>](https://codesponsor.io)<br />[💻](https://github.com/codesponsor/web/commits?author=coderberry "Code") [📖](https://github.com/codesponsor/web/commits?author=coderberry "Documentation") [📦](#platform-coderberry "Packaging/porting to new platform") | [<img src="https://avatars1.githubusercontent.com/u/660973?v=4" width="100px;"/><br /><sub><b>Miguel Angel Gordián</b></sub>](http://zoek1.github.com)<br />[💻](https://github.com/codesponsor/web/commits?author=zoek1 "Code") [📖](https://github.com/codesponsor/web/commits?author=zoek1 "Documentation") [🚇](#infra-zoek1 "Infrastructure (Hosting, Build-Tools, etc)") [📦](#platform-zoek1 "Packaging/porting to new platform") |
| :---: | :---: |
<!-- ALL-CONTRIBUTORS-LIST:END -->
