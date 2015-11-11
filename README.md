# Bibliotwitter
Forward reverse association counter for hashtags related to #datascience using Twitter API programed in Ruby

I recommend the Codecademy lesson on the Twitter API as a starting point. The "twitter" wrapper library also makes implementaion a lot easier.

In order to use this function you will need to install the twitter wrapper. On my mac this was as simple as typing the following into a terminal:
sudo gem install twitter
Other libraries may also need to be installed in a similar fashion "net" and maybe "oauth2"

You will also need to register a new application with twitter to recieve access tokens allowing you to acces the Twitter api.
Check out https://apps.twitter.com/ to do this. Then replace the code that says "<INSERT YOUR TOKEN HERE>" with the appropraite tokens obtained from the website

To run program from command line, cd to the folder containing the program and enter:
ruby BIBLIOTWITTER.rb

You could also change the initial search term (#datascience) to a term of interest to you.
