+++
categories = ["elixir"]
comments = true
date = "2018-10-18T20:32:00-00:00"
draft = false
showpagemeta = true
showcomments = true
slug = "elixir-dynamic-queries-with-ecto"
tags = ["elixir", "ecto", "database", "query", "graphql"]
title = "Composing dynamic queries with ecto"
description = "Composing non definite query structures with ecto"

+++
I was recently working on a project where I needed to compose a dynamic query for filtering a table using ecto. The filter parameters are coming from a graphql resolver.

```ruby
# ~/query.ex
  #A sample filter input
  filter_input = %{status: "AVAILABLE", genre: "Comedy", last_update_gte: "2018-10-18 00:00:00", last_update_lte: "2018-10-18 23:59:59" }
  
  #The schema I will be querying
  defmodule Movies do
    use Ecto.Schema
    schema "movies" do
      field(:genre, :string)
      field(:status, :string)
      timestamps()
    end
  end

  #My resolver function

  defmodule MovieFilter do
    import Ecto.Query

    def compose_filter(filter_params, base_query = %Ecto.Query{}) do
      filter_params
      |> Enum.reduce(base_query, fn filter, acc ->
        q =
          case filter do
            {:last_update_gte, value} -> dynamic([w], w.updated_at >= ^value)
            {:last_update_lte, value} -> dynamic([w], w.updated_at <= ^value)
            {:status, value} -> dynamic([w], w.status >= ^value)
            {:genre, value} -> dynamic([w], w.genre >= ^value)
          end

        where(acc, ^q)
      end)
    end
  end
  
  #usage
  base_query = from(m in Movies)

  MovieFilter.compose_filter(filter_input, base_query)
  |> Repo.all()

```

#### Explanation
With `compose_filter\2` we are able to compose a dynamic query, which is derived from user input depending on the desired filter fields, the result of the function which is then passed to `Repo.all()`

The `dynamic\2` in compose_filter function is imported from Ecto.Query as well as `where\3`

More about the dynamic function is [Here](https://hexdocs.pm/ecto/Ecto.Query.html#dynamic/2) in the official documentation of Ecto.