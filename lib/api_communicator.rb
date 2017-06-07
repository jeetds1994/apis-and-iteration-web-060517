require 'rest-client'
require 'json'
require 'pry'

def get_character_movies_from_api(character)
  #make the web request
  character_hash = get_JSON('http://www.swapi.co/api/people/')

  character_hash["results"].map do |char|
    if char["name"].downcase == character.downcase
      char["films"].each_with_object([]) do |filmURL, arr|
        arr.push(get_JSON(filmURL))
      end
    end
  end.flatten.compact
end

def get_JSON(url)
  restClientData = RestClient.get(url)
  movie_data = JSON.parse(restClientData)
end

def parse_character_movies(films_hash)
  if films_hash.size == 0
    puts "You're not a movie star yet!"
  else
    films_hash.each do |film|
      puts film["title"]
    end
  end
end

def show_character_movies(character)
  films_hash = get_character_movies_from_api(character)
  parse_character_movies(films_hash)
end

## BONUS

# that `get_character_movies_from_api` method is probably pretty long. Does it do more than one job?
# can you split it up into helper methods?
