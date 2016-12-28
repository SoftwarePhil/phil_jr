defmodule SpoonacularApi do
    
    def init(key) do
        Agent.start_link(fn -> key end, name: __MODULE__)
    end 
    @doc """ 
        gets a joke
        curl --get --include 'https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/jokes/random' \
        -H 'X-Mashape-Key: 9yzAdLPogemsha8Da4FMKOn6T38vp1ZOcj7jsnDdfDalVBmLaC' \
        -H 'Accept: application/json'
    """
    def joke do
        url = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/jokes/random"
        {:ok, result} = HTTPoison.get url, headers()
        
        Poison.decode!(result.body)
        |>Map.fetch!("text")
    end
    
    @doc """
        curl --get --include 'https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/convert?ingredientName=brown+rice&sourceAmount=2.5&sourceUnit=cups&targetUnit=grams' \
        -H 'X-Mashape-Key: 9yzAdLPogemsha8Da4FMKOn6T38vp1ZOcj7jsnDdfDalVBmLaC' \
        -H 'Accept: application/json'
    """
    def convert(ingredient, amount, unit, other_unit) do
        url = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/convert?ingredientName=#{space(ingredient)}&sourceAmount=#{amount}&sourceUnit=#{unit}&targetUnit=#{space(other_unit)}" 

        {:ok, result} = HTTPoison.get url, headers()
        result = Poison.decode!(result.body)
        
        case Map.fetch(result, "answer") do
            {:ok, answer} -> {:ok, answer}
            _ -> {:error, "bad input"}
        end      
    end

    defp space(string) do
        String.replace(string, " ", "+")
    end

    defp headers do
        key = Agent.get(__MODULE__, fn key -> key end)
        ["X-Mashape-Key": key, "Accept": "application/json"]
    end
 
end