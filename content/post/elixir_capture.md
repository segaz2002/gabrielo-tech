+++
categories = ["elixir"]
comments = true
date = "2017-09-14T21:56:13-04:00"
draft = false
showpagemeta = true
showcomments = true
slug = "elixir-capture-command"
tags = ["elixir", "capture", "copy", "operator", "anonymous"]
title = "Elixir capture(&) command"
description = "Simple explanation for the capture command"

+++

I intend to explain the usage of the capture (&) command in elixir for newbies like myself, base on my understanding at this point :).
It is barely 2 weeks since I started writing elixir as at the writing of this post, coming from node.js. 

The first time I came across the syntax below, I wondered what the f**k is happening here, but I after a while I grab it, 
thanks to google. :)

```ruby
iex(1)> {:ok, %{name: "bla bla"}} |> (& {:ok, %{}} = &1).()
{:ok, %{name: "bla bla"}}
```
#### Explanation
In the code above the right side is being pattern matched to the left side.

The left side `{:ok, %{name: "bla bla"}}` is piped (`|>`) to the match using the capture symbol `&` and the output is giving to
right side of my match `= &1`.

The trick here is that the capture symbol `&` writes `(fn(x) -> x)` under the hood and later the entire lambda function is
executed ``.()``.
