defmodule PhilJrBot do
    @my_key "xoxb-114233471719-W70Y0PyYjEv2cMiM1ZtGuiWd"
    
    def init do
        {:ok, rtm} = Slack.Bot.start_link(SlackRtm, [], @my_key)
        rtm
    end

    def send_message(rtm, message) do
        send rtm, {:message, "#{message}", "#general"}
    end
end