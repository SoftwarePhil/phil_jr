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

    def handle_event(message = %{type: "message", text: content}, slack, state) do 
        tree_response(message.user, content)
        |>send_message(message.channel, slack)
        {:ok, state}
    end

    def handle_event(_, _, state), do: {:ok, state}

    def tree_response(user, content) do
        status = case :ets.lookup(:chatters, user) do
            [] -> 
                :ets.insert(:chatters, {user, :first})
                :first
            [{_user, state}] -> state 
        end
        IO.inspect status
        {new_status, answer} = case status do
            :first -> first()
            :start -> start()
            :start_answer  -> start_answer(content)
            :buy?   -> buy(content)
            :done -> 
                :ets.delete(:chatters, user)
                {:first, "good bye!"}
        end

        case new_status do
            :bad -> "try again"
             _   -> 
                 :ets.insert(:chatters, {user, new_status})
                 answer
        end
    end

    def first do
        {:start, "hello!"}
    end

    def start do
        {:start_answer, "I am a food health bot. I want you to eat healthier! Do you have heart disease(HD), diabetes(DB), obesity(O), or neither(N)?"}
    end

    def start_answer(answer) do
        case String.downcase(answer) do
            "n" ->   
                {:buy?, "Here is your recipe! http://allrecipes.com/recipe/72381/orange-roasted-salmon/?internalSource=staff%20pick&referringId=84&referringContentType=recipe%20hub&clickId=cardslot%205\n if you would like to purchase these ingredients and have them delivered to your house type yes, if not have a nice day!!"}
            "hd" -> 
                {:buy?, "Here is your recipe! https://recipes.heart.org/recipes/1320/apple-nachos \n if you would like to purchase these ingredients and have them delivered to your house type yes, if not have a nice day!!"}
            "db" -> 
                {:buy?, "Here is your recipe! http://allrecipes.com/recipe/8628/yakisoba-chicken/?internalSource=hn_carousel%2001_Yakisoba%20Chicken&referringId=739&referringContentType=recipe%20hub&referringPosition=carousel%2001 \n if you would like to purchase these ingredients and have them delivered to your house type yes, if not have a nice day!!"}
            "o" -> 
            {:buy?, "Here is your recipe! http://allrecipes.com/recipe/18880/garys-turkey-burritos/?internalSource=staff%20pick&referringId=1231&referringContentType=recipe%20hub&clickId=cardslot%204 \n if you would like to purchase these ingredients and have them delivered to your house type yes, if not have a nice day!!"}
            _   ->   {:bad, :bad}
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

