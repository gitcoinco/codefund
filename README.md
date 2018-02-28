# Code Sponsor
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors)

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

## Install

Code Sponsor uses [Nanobox](https://nanobox.io) for development and deployment.

#### Install Nanobox

[Download and Install Nanobox](https://nanobox.io/download)

#### Clone the repo

    # clone the code
    git clone https://github.com/codesponsor/web.git

    # cd into the phoenix app
    cd web

#### Run the app

    # Add a convenient way to access your app from the browser
    nanobox dns add local phoenix.dev
    
    # Set up environment variables
    nanobox evar add local \
      MAILGUN_API_KEY=__MAILGUN_API_KEY__ \
      MAILGUN_DOMAIN=__MAILGUN_DOMAIN__ \
      SECRET_KEY_BASE=__SECRET_KEY_BASE__

    # Run phoenix
    nanobox run mix phx.server
    
#### Open in browser

Visit your app at [http://phoenix.dev](http://phoenix.dev)

#### Explore

With Nanobox, you have everything you need develop and run your phoenix app:

    # drop into a Nanobox console
    nanobox run

    # where elixir is installed,
    elixir -v

    # your packages are available,
    mix list

    # and your code is mounted
    ls

    # exit the console
    exit

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
| [<img src="https://avatars2.githubusercontent.com/u/12481?v=4" width="100px;"/><br /><sub><b>Eric Berry</b></sub>](https://codesponsor.io)<br />[💻](https://github.com/codesponsor/web/commits?author=coderberry "Code") [📖](https://github.com/codesponsor/web/commits?author=coderberry "Documentation") [📦](#platform-coderberry "Packaging/porting to new platform") |
| :---: |
<!-- ALL-CONTRIBUTORS-LIST:END -->
