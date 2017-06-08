require 'rest-client'
require 'json'
require 'pry'
require_relative "../lib/api_communicator.rb"
require_relative "../lib/command_line_interface.rb"

# retrieves the API data and parses it into JSON
def get_JSON(url)
  restClientData = RestClient.get(url)
  movie_data = JSON.parse(restClientData)
end

def get_character_movies_from_api(character)
  # make the web request
  counter = 0
  character_hash = get_JSON("http://www.swapi.co/api/people/?page=1")
  until character_hash["next"] == "null"
    counter += 1
    if counter > 1
      next_character_hash = get_JSON(character_hash["next"])
      (character_hash["results"] << next_character_hash["results"]).flatten
    end
  end
    # get a list of all the individual character hashes
    character_hash["results"].map do |char|
      # binding.pry
      # test to see if the character hash corresponds to the argument's character
      if char["name"].downcase == character.downcase
        # take all the film URLs and shovel them into a new array
        char["films"].each_with_object([]) do |filmURL, arr|
          arr.push(get_JSON(filmURL))
          break
        end
      else
        # tests for mispelled character name, and suggests a replacement
        did_you_mean?(char["name"].downcase, character.downcase)
      end
  end.flatten.compact
end

def get_all_data
  character_hash = get_JSON("http://www.swapi.co/api/people/?page=1")
  results_arr = []
  until character_hash["next"] == "null"
    results_arr << character_hash["results"]
    nextURL = character_hash["next"]
    binding.pry
    character_hash = get_JSON(nextURL)
  end
end

puts get_all_data

def did_you_mean?(compare2, orginal_input)
  even_score = 0
  odd_score = 0
  for i in 0...orginal_input.length
    if i.odd?
      if orginal_input[i] == compare2[i]
        odd_score += 1
      end
    elsif i.even?
      if orginal_input[i] == compare2[i]
        even_score += 1
      end
    end
  end
  if even_score >= orginal_input.length / 2 || odd_score >= orginal_input.length / 2
    capCompare = compare2.split.map {|word| word.capitalize}.join(" ")
    puts "Did you mean #{capCompare}? y/n"
    y_or_n = gets.chomp.downcase
    if y_or_n == "y"
      get_character_movies_from_api(capCompare)
    else
      puts "You're not a movie star yet!"
    end
  end
end



# takes the array of film hashes, checks if there was a valid match,
# if so, prints each film, sorted by release date
def parse_character_movies(films_array)
  if films_array.size == 0
    puts "You're not a movie star yet!"
  else
    films_array.sort_by {|hash| hash["release_date"] }.each_with_index do |film, index|
      puts "#{index +1}. #{film["title"]}"
    end
  end
end


def show_character_movies(character)
  films_array = get_character_movies_from_api(character)
  parse_character_movies(films_array)
end

# puts parse_character_movies(get_character_movies_from_api("Luke Skywalker"))

## BONUS

# that `get_character_movies_from_api` method is probably pretty long. Does it do more than one job?
# can you split it up into helper methods?

# Problem Solving Steps:
# 1. Look at what the JSON data looks like to the computer.
# 2. Figure out how to navigate to the character data in the JSON hash.
# 3. Create an if statement inside a map method to direct the method to the desired character hash.
# 4.
