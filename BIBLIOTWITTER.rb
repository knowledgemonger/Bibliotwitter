# simple script to search for forward and reverse associations in tweets with respect to a target hashtag of interest

require 'twitter' # This is a wrapper for the Twitter API (making the program easier to write and more readable)
require 'json' #JSON is the format of the data that twitter call will return. This library provides functions for working with this data format.
require 'net/http' # the is an HTTP Client API implementing the HTTP Internet standards

# first creat a new client of the Twitter API
client = Twitter::REST::Client.new do |config|
  # These tokens come from Twitter. To get tokens you have to register an application from twitter.
  # Go to https://apps.twitter.com/ to do this. Then after registering copy and paste each token from
  # the Twitter application management website
    config.consumer_key = "<INSERT YOUR TOKEN HERE>"
    config.consumer_secret = "<INSERT YOUR TOKEN HERE>"
    config.access_token = "<INSERT YOUR TOKEN HERE>"
    config.access_token_secret = "<INSERT YOUR TOKEN HERE>"
end

results=client.search('\"#datascience\"') # sends a query to twitter for the given string.
                                          # the \"s are included so that the query askes for an exact match.
                                          # matches are returned in the form of a API SearchResult object.
                      
                      
# I will first calculate a forward association for hashtags related to datascience as the number of times 
# a tweet found by searching for "#datascience" also contains these other hashtags
# I will then calculate a reverse association by counting the number of times a tweet found searching for each 
# hashtag in the list of forward associated hashtags contains the original hashtag, namely #datascience.
# I will then simply output these results to file for later analysis.

                  
forward_hash = Hash.new # A hash is a mapping between keys (in this case hashtags) and values (I will be storing
                        # the number of times each hashtag appered in a tweet that also had the #datascience hashtag)
forward_hash.default=0  # Since I will be counting appearances I want my hash to start with 0 so I
forward_count=0         # This variable will count the number of tweets that make it past my (incomplete) filter for retweets.

# I will call the twitter API to grab one tweet at a time from the search results (upto 10000) to search for hashtags
results.take(10000).collect do |tweet| # Collects 10000 tweets from the search and enumerates the results in a variable called tweet
  if  tweet.retweeted_status.nil?      # first filter for retweets: does the meta_data recognize this as a retweet
    text=tweet.text.scan(/[^\s\\]+/)   # break the text of the tweet into words stored in an array
    if text[0][-1]!=':'                # second filter: does the first word end in a colon (eg. username: assumed to indicate a quote)
      if text[0]!='RT'                 # third filter: is the first word RT short for retweet
        forward_count=forward_count+1  # increment count of tweets passing these filter
        tweet.text.scan(/#\w+/) do |octothorp| # find words in the text that begin with #
          forward_hash[octothorp[1..-1].capitalize]=forward_hash[octothorp[1..-1].capitalize]+1 # increment count of occurence of each hashtag
        end
      end
    end
  end
end

# Here I will save the data. I doubt this is the optimal way to save this data but its the first way that I found.
forwardfile=File.open('forward_hash','w') # make a new file for output 
forwardfile.puts forward_hash.sort_by{|hash,count|count} # output data 
forwardfile.close #close file

# repeat for second variable
forwardcountfile=File.open('forward_count','w')
forwardcountfile.puts forward_count
forwardcountfile.close

# Twitter puts limits on how many calls you can make to through their API in a 15 minute block.
# My inital runs kept returning "rate limit exceeded" errors
# To slow my program down I pause occasionally
sleep(10*60) # wait for 10 minutes

# make variables for reverse association
reverse_hash = Hash.new
reverse_hash.default=0

reverse_count = Hash.new
reverse_count.default=0

forward_hash.keys.each do |octothorp| # iterate over the hashtags found by forward association
  if forward_hash[octothorp]>1        # in the interest of time only consider hashtags present in at least 2 tweets
    sleep(60)                         # wait one minute to avoid Twitter's rate limit error
    results=client.search('\"'+octothorp+'\"')  # search the current hashtag
    results.take(1000).collect do |tweet|       # grab each tweet
      if  tweet.retweeted_status.nil?           # filter for retweets
        text=tweet.text.scan(/[^\s\\]+/)
        if text[0][-1]!=':'
          if text[0]!='RT'
            reverse_count[octothorp]=reverse_count[octothorp]+1 # count number of tweets passing filters
            if text.map(&:downcase).include?('#datascience')    # does tweet also contain #datascience hashtag?
              reverse_hash[octothorp]=reverse_hash[octothorp]+1 # if so increment reverse association
            end  
          end
        end
      end
    end
  end
end

# save results to file
reversefile=File.open('reverse_hash','w')
reversefile.puts reverse_hash.sort_by{|hash,count|count}
reversefile.close

reversecountfile=File.open('reverse_count','w')
reversecountfile.puts reverse_count.sort_by{|hash,count|count}
reversecountfile.close

