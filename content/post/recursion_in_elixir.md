+++
categories = ["elixir"]
comments = true
date = "2017-09-21T17:29:13-04:00"
draft = false
showpagemeta = true
showcomments = true
slug = "elixir-recursion"
tags = ["elixir", "recursion"]
title = "Recursion in elixir"
description = "How to perform recursion in elixir "

+++
I am new to elixir, and I find this interesting at the time of writing, I am coming from NodeJs :)

The major ingredients of recursion are:
- An exercise to perform repeatedly, 
- A condition to break off the repeated exercise

Lets say we want to write a function that will return building identifiers where restaurants have not yet closed. 
The first argument is the current hour as integer, the second argument is the current minute as integer, the third argument
is the list of restaurants containing; the name of the canteen, building identifier, closing hour, closing minute.

```bash
mix new restaurant
```

```ruby
# ~/restaurant/lib/restaurant.ex

defmodule Restaurant do
  defstruct name: nil, id: nil, closing_hour: nil, closing_minute: nil

	def get_opened(hour, minute, restaurants) do
		check_if_opened(hour, minute, restaurants, [])
	end

	defp check_if_opened(hour, minute, [restaurant = %Restaurant{closing_hour: c_hour, closing_minute: c_minute} | tail], accumulator)
    do
      case (c_hour >= hour) do
        true when (c_hour != hour) -> check_if_opened(hour, minute, tail, (accumulator ++ [restaurant]))
        true when (c_hour == hour) -> fn  ->
            case (minute < c_minute) do
              true -> check_if_opened(hour, minute, tail, (accumulator ++ [restaurant]))
              false -> check_if_opened(hour, minute, tail, accumulator)
            end
          end.()
        false -> check_if_opened(hour, minute, tail, accumulator)
      end
  end
	defp check_if_opened(_, _, [], acummulator) do
		acummulator
  end
end
```

#### Explanation
`get_opened\3` is the public function that is called, and this is given the parameters described earlier, the hour, minute and 
the list of restaurants we want to check recursively using the `check_if_opened\4` function. There are two `check_if_opened\4` functions, 
thanks to the magic of elixir, this is pattern matching at work. When `check_if_opened\4` is called it will only match one based on the parameters 
defined on the function.

In our case we have `check_if_opend\4` which is targeting an empty restaurant list and another one which will match a non empty list. 
Which is our golden plan of breaking off from the recursion.

This comes to mind when looking at this solution "An Enum method could have been used to operate on the restaurant list", yes, this is possible
but the objective of this snippet is to demonstrate the explicit filtering of the restaurants in order to showcase recursion in elixir.

Let's test our restaurant module:

```ruby
#~/restaurant/test/restaurant_test.exs
defmodule RestaurantTest do
  use ExUnit.Case

  setup_all do
    restaurants_list = [
      %Restaurant{name: "Kohvic center", id: "KHV", closing_hour: 16, closing_minute: 30},
      %Restaurant{name: "Kohvic center2", id: "KHV2", closing_hour: 14, closing_minute: 00},
      %Restaurant{name: "Liivi 2 Restaurant", id: "Liivi-2", closing_hour: 19, closing_minute: 45},
    ]
    {:ok, [restaurants: restaurants_list]}
  end

  test "check available restaurants for 16:46", %{restaurants: restaurants} do
    assert [%Restaurant{id: "Liivi-2"}] = Restaurant.get_opened(16, 46, restaurants) #One restaturant should be opened
  end

  test "check available restaurants for 18:46", %{restaurants: restaurants} do
    assert 0 = length(Restaurant.get_opened(19, 46, restaurants)) #All restaurants should be closed for this time
  end

  test "check available restaurants for 13:00", %{restaurants: restaurants} do
    assert 3 = length(Restaurant.get_opened(13, 00, restaurants)) #All restaurants should be opened by this time
  end
```