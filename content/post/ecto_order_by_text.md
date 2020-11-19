+++
categories = ["elixir", "ecto", "database"]
comments = true
date = "2020-11-18T20:38"
draft = true
showpagemeta = true
showcomments = true
slug = "ecto-order-by-text-field"
tags = ["elixir", "ecto", "order_by", "fragments"]
title = "Elixir capture(&) command"
description = "Order query results by text field"

+++

This post demonstrates how to order an ecto query by a text field.
by sending the order raw sql query through [Ecto.Query.API.fragment/1](https://hexdocs.pm/ecto/Ecto.Query.API.html#fragment/1)


#### Sample table
Assuming we want to query a table containing a list of scheduled jobs with known statuses. e.g 
`RUNNING`, `PENDING`, `COMPLETED`, `FAILED`
| id  | task_ref  | status    |  last_exec_timestamp|
|---------------- | --------------- | --------------- | --------------- |
| 1    | 2232323    | PENDING    |1605726253|
| 2    | 2232324    | FAILED    |1605726153|
| 4    | 2232326   | RUNNING   |1605726233|
| 5    | 2232326   | RUNNING   |1605726233|
| 6    | 2232326   | FAILED   |1605726233|
| 7    | 2232326   | COMPLETED   |1605726233|
| 8    | 2232326   | FAILED   |1605726233|

Our objective is to:
- Fetch all rows
- Order the rows in the following order
    `RUNNING > PENDING > COMPLETED > FAILED`

Off we go
```ruby
 #SomeModule
 import Ecto.Query

 @statuses_order """
    (case(?)
      when 'RUNNING' then 1
      when 'PENDING' then 2
      when 'COMPLETED' then 3
      else 4
    end)
  """
 def your_function do
    from(j in Jobs)
    |> order_by([j], asc: fragment(@statuses_order, j.status))
    |> Repo.all()
 end

```

Just like that our jobs records will be returned in the order which we have specified in the `@statuses_order` module attribute string.

More information about this subject from elixir forum can be found here [here](https://elixirforum.com/t/error-interpolating-a-variable-as-the-first-argument-of-an-ecto-fragment/6711/2).

Thats it! :) 

