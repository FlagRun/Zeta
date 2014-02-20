module Plugins
  class Movies
    include Cinch::Plugin
    set(
     plugin_name: 'Random Attacker',
     help: 'Movie Plot\nUsage: `!movie <name of movie>`;',
     react_on: :channel
    )

    match /movie (.*)/, method: :find_movie
    def find_movie(m, movie)
      data = query_movie(movie)
      if data && data.response == 'True'
        m.reply "Movie> #{data.title} (#{data.year}) <#{data.rated}> #{data.plot.to_s.strip[0..800]} [www.imdb.com/title/#{data.imdbid}/]"
      else
        m.reply 'Unable to find movie!'
      end
    end

    private
    def query_movie(q)
      movie = URI.encode(q)
      data = JSON.parse(open("http://www.omdbapi.com/?t=#{movie}").read)
      OpenStruct.new(
          title:       data['Title'],
          year:        data['Year'],
          rated:       data['Rated'],
          released:    data['Released'],
          runtime:     data['Runtime'],
          genre:       data['Genre'],
          director:    data['Director'],
          writer:      data['Writer'],
          actors:      data['Actors'],
          plot:        data['Plot'],
          language:    data['Language'],
          country:     data['Country'],
          awards:      data['Awards'],
          poster:      data['Poster'],
          metascore:   data['Metascore'],
          imdbrating:  data['imdbRating'],
          imdbvotes:   data['imdbVotes'],
          imdbid:      data['imdbID'],
          type:        data['Type'],
          response:    data['Response']
      )
    rescue
      nil
    end


  end
end
