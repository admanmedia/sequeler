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


## Development

Open an interactive terminal with `iex -S mix`. That will get you a server
on port 4000. Then you can play:

```
$ iex -S mix
Erlang/OTP 17 [erts-6.2] [source] [64-bit] [smp:2:2] [async-threads:10] [hipe] [kernel-poll:false]

Running Sequeler on http://localhost:4000
Interactive Elixir (1.0.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> k = "testingphrasesforencryption" |> Cipher.generate_key
"c7eaba361111a87f"
iex(2)> i = "testingphrasesforencryption" |> Cipher.generate_iv
"testingphrasesfo"
iex(3)> sql = "show tables" |> URI.encode_
encode_query/1       encode_www_form/1
iex(3)> sql = "show tables" |> URI.encode_www_form
"show+tables"
iex(4)> url = "/query?sql=" <> sql
"/query?sql=show+tables"
iex(5)> signed_url = url |> Cipher.sign_url(k,i)
"/query?sql=show+tables&signature=dN0s%2FVZJw%2FlWANRARyb0IvUBnKC1in4GEdVMI13Zy0oBr%2FHx28rNvU5q2nXOyDw%2F"
iex(6)> complete_url = "http://localhost:4000" <> signed_url |> to_char_list
'http://localhost:4000/query?sql=show+tables&signature=dN0s%2FVZJw%2FlWANRARyb0IvUBnKC1in4GEdVMI13Zy0rS%2B9o73VsFLvS6jp%2BZkBEU'
iex(7)> :httpc.request(complete_url)
{:ok,
 {{'HTTP/1.1', 200, 'OK'},
  [{'cache-control', 'max-age=0, private, must-revalidate'},
   {'connection', 'keep-alive'}, {'date', 'Mon, 10 Nov 2014 11:13:09 GMT'},
   {'server', 'Cowboy'}, {'content-length', '10'},
   {'content-type', 'application/json'}], '[["test"]]'}}
```
