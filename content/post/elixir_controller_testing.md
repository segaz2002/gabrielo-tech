+++
categories = ["elixir"]
comments = true
date = "2017-10-25T09:47:13-04:00"
draft = false
showpagemeta = true
showcomments = true
slug = "elixir-controller-testing"
tags = ["elixir", "plug", "controller", "testing"]
title = "Testing a phoenix controller"
description = "Elixir phoenix controller test with Plug.Test"

+++
The snippet below is a phoenix framework controller test
 
```ruby
defmodule PaymentServiceWeb.Controllers.PaymentTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias PaymentServiceWeb.Router

  @tag endpoint: true
  test "service health check" do
    conn = conn(:get, "/api")
    response = Router.call(conn, @opts)
    assert %Plug.Conn{resp_body: body} = response
  end
  
end
```
#### Explanation
The test above is going to test an api endpoint, and the simple assertion is just to ensure that a `%Plug.Conn` struct is received as the 
response. `conn/3` is used to issue a get request to the endpoint, where the 3rd parameter and be the request body in the case of a post request.



