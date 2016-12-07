defmodule SlackRtm do
    use Slack

    def handle_connect(slack, state) do
        IO.puts "Connected as #{slack.me.name}"
        {:ok, state}
    end

    def handle_event(message = %{type: "message", text: content}, slack, state) when content == "hello" do 
        IO.inspect message
        name = Slack.Lookups.lookup_user_name(message.user, slack)
        send_message("hello, #{name} sir", message.channel, slack)
        {:ok, state}
    end

    def handle_event(message = %{type: "message", text: content}, slack, state) when content == "how are you?" do 
        send_message("I am doing fucking great", message.channel, slack)
        {:ok, state}
    end

    def handle_event(message = %{type: "message"}, slack, state) do
        send_message("I got a message!", message.channel, slack)
        {:ok, state}
    end

    def handle_event(_, _, state), do: {:ok, state}

    def handle_info({:message, text, channel}, slack, state) do
        IO.puts "Sending your message, captain!"
        send_message(text, channel, slack)
        {:ok, state}
    end

    def handle_info(_, _, state), do: {:ok, state}
end
#Slack.Bot.start_link(SlackRtm, [], "TOKEN_HERE")
#Slack.Bot.start_link(SlackRtm, [], "xoxb-114233471719-W70Y0PyYjEv2cMiM1ZtGuiWd")

#{:ok, rtm} = Slack.Bot.start_link(SlackRtm, [], "xoxb-114233471719-W70Y0PyYjEv2cMiM1ZtGuiWd")
#send rtm, {:message, "External message", "#general"}