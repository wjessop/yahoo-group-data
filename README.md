# yahoo-group-data gem

Yahoo doesn't provide an API to it's publicly available group info, so this gem covers that gap. Use it to find out the publicly available group information of a Yahoo group such as name, description and relevant email addresses.

## Example

``` ruby
require 'yahoo-group-data'

g = YahooGroupData.new("http://tech.groups.yahoo.com/group/OneStopCOBOL/")

name = g.name
description = g.description

p = g.post_email
s = g.subscribe_email
u = g.unsubscribe_email
o = g.unsubscribe_email
```

## Requirements

It's tested with Ruby 1.9.3, it probably works with older versions.

## Installation

Add this line to your application's Gemfile:

    gem 'yahoo-group-data'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yahoo-group-data

## TODO

* Parse out
* * Number of members
* * Founded date
* * Category
* * Language

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

*pull requests with tests are more likely to be accepted*

### Testing

Rather than distribute a load of Yahoo's HTML pages with the gem there's a rake task to get the ones that are needed. Run:

	`rake fetch_yahoo_pages`

after that:

	rake test

### If you find a group the gem fails on

Tell me about it, or (in preference) update the gem (Hint: start by adding an entry to the groups.yml file), see contributing instructions above.