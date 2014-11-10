# Sequeler

A simple server written in Elixir that receives a request,
performs a query to a MySQL backend, and returns the response in JSON format.

It sits on top of [Cowboy](https://github.com/ninenines/cowboy)
through a [Plug](https://github.com/elixir-lang/plug) layer,
uses [Emysql](https://github.com/Eonblast/Emysql) to communicate with MySQL,
and uses [Jazz](https://github.com/meh/jazz) to work with JSON.

The plan is to use [Cipher](https://github.com/rubencaro/cipher), a cipher
compatible with [this spec](https://gist.github.com/rubencaro/9545060#file-gistfile3-ex).
This way it can be used from Python, Ruby or Elixir apps.

There should be some tight query timeout, and maybe some injection
prevention measures mainly to avoid accidents (requests are already signed).

~~I will use [exrm](https://github.com/bitwalker/exrm) to manage releases.~~
(Seems too hacky to be used by now, SSL compiling problems)

I will use a [custom docker image](https://registry.hub.docker.com/u/rubencaro/elixir_mysql/)
based on [trenpixster docker image for elixir](https://registry.hub.docker.com/u/trenpixster/elixir/)
to ease development environment setup and use. That and some simple helper scripts to manage it.
