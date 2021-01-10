+++
categories = ["elixir"]
comments = true
date = "2017-12-27T21:40:13-04:00"
draft = false
showpagemeta = true
showcomments = true
slug = "elixir-telegram-bot"
tags = ["elixir", "telegram", "bot", "GenServer"]
title = "Elixir Telegram Bot"
description = "Telegram Bot backend implementation with elixir"

+++

The quest was to develop a telegram bot over 24hrs, during an office hackathon event.

I started out consulting <a href="https://core.telegram.org/bots">documentation</a>.

Bot interaction was implemented as a GenServer named `ConversationTree`


```ruby
    defmodule TelegramService.ConversationTree do
      use GenServer

      def start_link(name, conversation \\ %{message: [], response: [], tickets: []}) do
        {:ok, _} = GenServer.start_link(__MODULE__, conversation, name: name)
        name
      end

      def lookup(name) do
        GenServer.whereis(name)
      end

      def kill(name) do
        GenServer.stop(name)
      end

      def write_message(name, message = %{}) do
        GenServer.call(name, {:write_message, message})
      end

      def write_response(name, message = %{}) do
        GenServer.call(name, {:write_response, message})
      end

      def put_ticket(name, ticket_info= %{}) do
        GenServer.call(name, {:put_ticket, ticket_info})
      end

      def clear_all(name) do
        GenServer.call(name, {:clear_all})
      end

      def retrieve(name) do
        GenServer.call(name, {:retrieve})
      end

      def init(conversation) do
        {:ok, conversation}
      end

      def handle_call({:clear_all}, _from, %{message: _, response: _, tickets: _}) do
        conversation = %{message: [], response: [], tickets: []}
        {:reply, :ok, conversation}
      end

      def handle_call({:put_ticket, payload}, _from, %{message: messages, response: answers, tickets: tickets}) do
        conversation = %{message: messages, response: answers, tickets: tickets ++ [payload]}
        {:reply, :ok, conversation}
      end

      def handle_call({:write_message, payload}, _from, %{message: messages, response: answers, tickets: tickets}) do
        conversation = %{message: messages ++ [payload], response: answers, tickets: tickets}
        {:reply, :ok, conversation}
      end

      def handle_call({:write_response, payload}, _from, %{message: messages, response: answers, tickets: tickets}) do
        conversation = %{message: messages, response: answers ++ [payload], tickets: tickets} 
        {:reply, :ok, conversation}
      end

      def handle_call({:retrieve}, _from, conversation = %{message: _, response: _, tickets: _}) do
        {:reply, {:ok, conversation}, conversation}
      end

    end
```
#### Explanation
So, the main idea is to create a new instance of the `ConversationTree` per chat received from the Telegram service.
The strategy adopted was to set a webhook endpoints which gets a POST request when ever a user engage the Bot.

 * `message` list in the state maintained by the `ConversationTree`, is to persist all incoming messages, a user sends to the Bot.
 * `tickets` is peculiar to the business logic for which I was developing the bot for as at this time. Basically you can add aditional fields as required.
 * `response` is a list of responses sent back to the user via the Bot. A response structure is describe below
    ```ruby
      %{text: text, options: options, next_actor: next_actor} = response
      %{module: module_name, action: action_in_module} = next_actor
    ```
    For the every response sent to the user, a `list` of options are provided to the user to choose from using the telegram <a href="https://core.telegram.org/bots#keyboards">keyboad</a> method
    from which the next message a user sends back is taken.
    Along side with the options sent back to the user, the next `actor` to act on an incoming message selected from list of options provided, this will give us the upportunity send the user response
    to the appropriate `Module.Action` using `apply/3`.

    ```ruby
      conversation = %{options: last_options, next_actor: %{module: actor_module, action: actor_action}, text: _} 
      apply(Module.concat(TelegramService, actor_module), String.to_atom(actor_action), [incoming_message, chat_id, message_id])
    ```

And this goes on and on inline with you business logic.

:)
