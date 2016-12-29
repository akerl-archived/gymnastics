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

## Strategy

Here's the query I'm using for the 1st pass of my draft:

```
mine = (
    # Folks who compete well in all 4 events
    g.select { |x| x.competes(0.8, 9.5).size > 3 } + \
    # Folks who compete great in 2+ events
    g.select { |x| x.competes(0.8, 9.8).size > 1 } + \
    # Folks who compete excellently in any event
    g.select { |x| x.competes(0.7, 9.9).size > 0 } + \
    # Folks who get 10s
    g.select { |x| EVENTS.select { |y| x.scores.send(y).select { |z| z == 10 }.size > 0 }.size > 0 } + \
    # Folks who always compete in 3 or more events
    g.select { |x| x.competes(1.0, 9.6).size > 2 } + \
    # Star freshmen
    %w(mykaylaskinner maggienichols ameliahundley).map { |x| find x } + \
    # Promising freshmen
    %w(kennediedney maddiekarr kimtessen taylorhouchin cassidykellen racheldickson graceglenn wynterchilders missyreinstadtler samogden).map { |x| find x } \
).uniq
# Reject injured athlete
mine.reject! { |x| x.name == 'kaseyjanowicz' }
```
