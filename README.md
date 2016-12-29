gymnastics_math
===============

Some random scripts/data/etc from playing with some data science for fantasy NCAA gymnastics

## Scripts

### avail.rb

Parses the downloaded HTML from http://www.collegefantasygymnastics.com/draft (must be logged in) to get a list of all available gymnasts. It expects to find the HTML in a file called `draft_list.html` in the current directory: it's not smart enough to download it itself.

### recorded.rb

Pulls the index from http://www.roadtonationals.com and records which gymnasts have stats available from 2016.

### diff.rb

Compares the lists from avail.rb and recorded.rb, logging matches in `found.txt` and misses in `wildcards.txt`. Wildcards are mostly freshman, and the script has a hardcoded list of special cases for gymnasts that switched schools since last year.

### stats.rb

Pulls stats for the gymnasts in `found.txt` from http://www.roadtonationals.com and records them in the `./stats` directory.

### math.rb

Open a REPL with the gymnasts loaded in for data manipulation.

