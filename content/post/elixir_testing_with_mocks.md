+++
categories = ["elixir"]
comments = true
date = "2018-05-08T21:50:00-04:00"
draft = false
showpagemeta = true
showcomments = true
slug = "elixir-tests-with-mocks"
tags = ["elixir", "testing", "mocking"]
title = "Testing with Mocks"
description = "Mocking functions that returns different results with different inputs in elixir"

+++
The situation was that, I needed to mock multiple external service within my application in order to test my application.

These external services are being consumed using HTTPPoison the popular elixir http client. The mock is achieved using the [Mock](https://github.com/jjh42/mock) library


```ruby
# ~/multi_mocks.exs
  #Mock multiple functions of the same module
  test "Test special service that will call other supporting endpoints" do
    with_mock(
      HTTPoison,
      post!: fn
        endpoint_a, _, _ -> %HTTPoison.Response{body: endpoint_a_response_body}
        endpoint_b, _, _ -> %HTTPoison.Response{body: endpoint_b_response_body}
        endpoint_c, _, _ -> %HTTPoison.Response{body: endpoint_c_response_body}
      end
    ) do
      assert {:ok, _} = call_to_special_servicer()
    end
  end

  #Mock multiple modules with their functions
  with_mocks([
        {ModuleA, [],
         [
           function_a: fn _, _ -> mock_desired_return end,
           function_b: fn _, _ -> mock_desired_return end
         ]},
        {ModuleB, [], [function_c: fn _, _ -> mock_desired_return end]},
        {ModuleC, [],
         [
           function_d: fn _ -> mock_desired_return end,
           function_e: fn _ -> mock_desired_return end
         ]}
      ]) do
        assert left = right
      end
```

#### Explanation
when `call_to_special_service\0` is called from within the test, during execution when `HTTPPoison.post!\3` fired with the given endpoints as url, the call results to the respective responses. With this we can easily pretend as if it was the real external service that was in action.


