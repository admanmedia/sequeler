# Sequeler

A simple server written in Elixir that receives a request,
performs a query to a MySQL backend, and returns the response in JSON format.

It sits on top of [Cowboy](https://github.com/ninenines/cowboy)
through a [Plug](https://github.com/elixir-lang/plug) layer,
uses [Emysql](https://github.com/Eonblast/Emysql) to communicate with MySQL,
and uses [Jsex](https://github.com/talentdeficit/jsex) to work with JSON.

The plan is to use a crypted key to validate signed requests, with a cipher
compatible with [this one](https://gist.github.com/rubencaro/9545060#file-gistfile3-ex).
This way it can be used from Python, Ruby or Elixir apps.

There should be some tight query timeout, and maybe some injection
prevention measures mainly to avoid accidents (requests are already signed).

I will use [exrm](https://github.com/bitwalker/exrm) to manage releases.
