require 'pry'
require 'csv'
require 'shotgun'
require 'sinatra'

def csv_data(file)
  league_arr = []

    CSV.foreach(file, headers: true) do |entry|
      score = {}
        score[:home_team] = entry[0]
        score[:away_team] = entry[1]
        score[:home_score] = entry[2]
        score[:away_score] = entry[3]

        league_arr << score
    end
  league_arr
end

def preseason(startingpoint)
  record = {}
  startingpoint.each do |x|
    if !record.has_key?(x[:home_team])
      record[x[:home_team]] = {"W" => 0, "L" => 0}
    end
    if !record.has_key?(x[:away_team])
      record[x[:away_team]] = {"W" => 0, "L" => 0}
    end
  end
  record
end

#find a better way to sort, not really gonna work with this (possibly sort.by)
def find_teams(league)
  teams = []
  league.each do |team|
    teams << team[:home_team]
    teams << team[:away_team]
  end
  uniq_teams = teams.uniq!
end

# apply some form of assignment with counting index from above (similar to cash register stuff)
# each team must increment whether win or lose (to be able to sort by wins and losses)
def games(meeting, record)
  meeting.each do |play|
    if play[:home_score].to_i > play[:away_score].to_i
      record[play[:home_team]]["W"] += 1
      record[play[:away_team]]["L"] += 1
    else play[:home_score].to_i < play[:away_score].to_i
      record[play[:away_team]]["W"] += 1
      record[play[:home_team]]["L"] += 1
    end
  end
  record
end

def standings(rankings)
  rankings.sort_by {|key, value| value["W"] && value["L"]}
end

#### here's where the problem is (too many "teams")
## per ruby doc -- *** must set value to nil first

def team_select(rankings, team)
  which_team = nil
  rankings.each do |squad, record|
    if squad == team
      which_team = record
    end
  end
  which_team
end

# just grabs team whether they're home or away
def history(points, franchise)
  points.select do |game| game[:home_team] == franchise || game[:away_team] == franchise
  end
end

## Faizaan said to do this in " 'get' " section using before....need to work on this

results = csv_data('finalscores.csv')
records = preseason(results)
rankings = games(results, records)

####################################################################################

get'/' do
  @team_selector = find_teams(results)

  erb :display
end

get '/leaderboard' do
  @rankings = standings(rankings)

  erb :index
end

get '/teams/:team' do
  @games = history(results, params[:team])
  @team = team_select(rankings, params[:team])

  erb :show
end
