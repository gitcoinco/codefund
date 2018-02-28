# Code Sponsor

Code Sponsor is an sponsorship platform to help fund open source projects and developers. Learn more at [https://codesponsor.io](https://codesponsor.io)

Here are a few blog posts and podcasts that discuss Code Sponsor:

* [Fighting for Open Source Sustainability: Introducing Code Sponsor](https://medium.com/code-sponsor/fighting-for-open-source-sustainability-introducing-code-sponsor-577e0ccca025)
* [Why Funding Open Source is Hard](https://medium.com/@codesponsor/why-funding-open-source-is-hard-652b7055569d)
* [Code Sponsor + Gitcoin = OSS Sustainability](https://medium.com/gitcoin/code-sponsor-gitcoin-oss-sustainability-5684c4adf4b4)
* [Sustaining Open Source](https://startupcto.io/podcast/0-57-sustaining-open-source-w-eric-berry-codesponsor-io/)
* [Sustaining Open-Source Software through Ethical Advertising](https://devchat.tv/js-jabber/jsj-281-codesponsor-sustaining-open-source-software-ethical-advertising-eric-berry)

## What is this?

This is the software behind [codesponsor.io](https://codesponsor.io). It's an [Elixir](http://elixir-lang.org) application built on the [Phoenix](http://www.phoenixframework.org) web framework, [PostgreSQL](https://www.postgresql.org), and [many](https://github.com/codesponsor/web/blob/master/mix.exs) [other](https://github.com/codesponsor/web/blob/master/assets/package.json) great open source efforts.

## Why is it open source?

A few reasons:

1. We _love_ open source. Our careers (and livelihoods) wouldn't be possible without open source. Keeping it closed just feels _wrong_.
2. Phoenix is really great, but it's young enough in its lifecycle that there aren't _too many_ in-production, open source sites for people to refer to as examples or inspiration. We want to throw our hat into that ring and hopefully others will follow.
3. We know open sourcing the platform will lead to good things from y'all (such as bug reports, feature requests, and pull requests).

## Should I fork this and use it as a platform?


## What is it good for?

If you're building a web application with Phoenix (or aspire to), this is a great place to poke around and see what one looks like when it's all wired together. It's not perfect by any means, but it works.

If you have questions about any of the code, holler [@codesponsor](https://twitter.com/codesponsor). You can also [join the slack group](https://slack.codesponsor.io) to discuss features and future development.

## Can I contribute?

Absolutely! Please remember that we have a product roadmap in mind so [open an issue](https://github.com/codesponsor/web/issues) about the feature you'd like to contribute before putting the time in to code it up. We'd hate for you to waste _any_ of your time building something that may ultimately fall on the cutting room floor.

## Code of Conduct

[Contributor Code of Conduct](https://github.com/codesponsor/web/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## How do I run the code?

Assuming you're on macOS:

  1. `./script/setup`
  2. `mix ecto.setup`
  3. `mix phx.server`

Now visit [`localhost:4000`](http://localhost:4000) in your browser.
The database contains some seed data you can start with.

#### Nanobox ENV Variables

    nanobox evar add local \
      MAILGUN_API_KEY=__MAILGUN_API_KEY__ \
      MAILGUN_DOMAIN=__MAILGUN_DOMAIN__ \
      DATA_REDIS_PASSWORD=__PASSWORD__ \
      SECRET_KEY_BASE=__SECRET_KEY_BASE

Generate the `SECRET_KEY_BASE` with `mix phoenix.gen.secret`

## Contributors
