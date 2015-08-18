module Plugins
  class Movie
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl

    set(
     plugin_name: 'Movie',
     help: 'Movie Plots \nUsage: `?movie <name of movie>`;',
     react_on: :channel
    )

    match /movie (.*)/, method: :find_movie
    def find_movie(m, movie)
      data = query_movie(movie)
      if data && data.response == 'True'
        m.reply "Movie ⊥ #{data.title} (#{data.year}) <#{data.rated}> #{data.plot.to_s.strip[0..800]} [www.imdb.com/title/#{data.imdbid}/]"
      elsif data && data.response == 'False'
        m.reply data.error
      else
        m.reply 'Unable to find movie!'
      end
    end

    private
    def query_movie(m)
      year = m[/:\d+/].gsub(/:/, '') if m[/:\d+/]
      movie = URI.encode(m.gsub(/:\d+/, ''))
      data = JSON.parse(
          # RestClient.get("http://www.omdbapi.com/?t=#{movie}&y=#{year}")
          open("http://www.omdbapi.com/?t=#{movie}&y=#{year}").read
      )
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
          response:    data['Response'],
          error:       data['Error']
      )
    rescue
      nil
    end


  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Movie
