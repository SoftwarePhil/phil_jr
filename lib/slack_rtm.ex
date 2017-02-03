defmodule SlackRtm do
    use Slack
    alias SpoonacularApi, as: Spoon

    def make_ets do
        :ets.new(:chatters, [:set, :public, :named_table])
    end

    
    def handle_connect(slack, state) do
        IO.puts "Connected as #{slack.me.name}"
        {:ok, state}
    end

     def handle_event(_message = %{subtype: subtype}, _slack, state) when subtype == "bot_message" do 
        IO.puts "bot message"
        {:ok, state}
    end

     def handle_event(message = %{type: "message", text: content}, slack, state) when content == "tell me a joke" do 
        send_message(Spoon.joke, message.channel, slack)
        {:ok, state}
    end

    def handle_event(message = %{type: "message", text: content}, slack, state) do 
        tree_response(message.user, content)
        |>send_message(message.channel, slack)
        {:ok, state}
    end

    def handle_event(_, _, state), do: {:ok, state}

    def tree_response(user, content) do
        status = case :ets.lookup(:chatters, user) do
            [] -> 
                :ets.insert(:chatters, {user, :start})
                :start
            [{_user, state}] -> state 
        end
        IO.inspect {status, content}
        {new_status, answer} = case status do
            :start -> start()
            :start_answer  -> start_answer(content)
            :type? -> meal(content)
            :health -> health(content)
            :buy?  -> buy(content)
            :done -> 
                :ets.delete(:chatters, user)
                {:first, "good bye!"}
        end

        IO.puts new_status

        case new_status do
            :bad -> "try again"
             _   -> 
                 :ets.insert(:chatters, {user, new_status})
                 answer
        end
    end

    def start do
        {:start_answer, "Hello, I am a food health bot. I want you to eat healthier! What kind of food are you in the mood for Italian(I), Chineese(C), Hispanic(H), or Other(O). Type I, C, H or O"}
    end

    def start_answer(answer) do
        IO.inspect answer
        case String.downcase(answer) do
            "i" -> {:type?, "What type of meal are you looking for breakfast(B), lunch(L), Dinner(D), or a snack(S). Type B, L, D, or S"}
             _  -> {:bad, :bad}
        end
    end

    def meal(answer) do
        case String.downcase(answer) do
            "l" -> {:health, "Okay, do you have any health restrictions? (yes or no)"}
            _   -> {:bad, :bad}
        end
    end

    def health(answer) do
        case String.downcase(answer) do
            "no" -> {:buy?, "Here is your recipe!! http://allrecipes.com/recipe/54165/balsamic-bruschetta/?internalSource=recipe%20hub&referringContentType=search%20results&clickId=cardslot%2062 \n Would you like to purchase this meal and have the ingredients delivered to your house? (type yes or no)"}
            _  -> {:done, "try and get healthier"}
        end
    end

    def buy(answer) do
        case String.downcase(answer) do
            "yes" -> {:done, "Okay all ingredients are being shipped to your house!  Thanks for your purchase!"}
             _  -> {:done, ")= Okay .."}
        end
    end

    def handle_info({:message, text, channel}, slack, state) do
        IO.puts "Sending your message, captain!"
        send_message(text, channel, slack)
        {:ok, state}
    end

    def handle_info(_, _, state), do: {:ok, state}
end

