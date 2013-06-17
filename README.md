[![Build Status](https://secure.travis-ci.org/wjessop/yahoo-group-data.png?branch=master)](https://travis-ci.org/wjessop/yahoo-group-data)

# yahoo-group-data gem

Yahoo doesn't provide an API to it's publicly available group info, so this gem covers that gap. Use it to find information about a Yahoo group such as name, description and relevant email addresses.

## Example

``` ruby
require 'yahoo-group-data'

g = YahooGroupData.new("http://tech.groups.yahoo.com/group/OneStopCOBOL/")

name = g.name
description = g.description
num_members = g.num_members

p = g.post_email
s = g.subscribe_email
u = g.unsubscribe_email
o = g.unsubscribe_email

json = g.to_json
```

### Available instance methods

These should be relatively self-explanatory. Where the data is unnavailable (for instance the group name if no group was found) the return value will be nil

#### Boolean values:

- not_found?
- private?
- age_restricted?
- no_data? (true if any of the above are true, othersise false. Here for convenience)

#### String values

- name
- description
- post_email
- subscribe_email
- owner_email
- unsubscribe_email
- language
- category
- to_json

#### Other values

- num_members (Integer)
- founded (Date)

## Requirements

It's tested with Ruby 1.9.3, it probably works with older versions.

## Installation

Add this line to your application's Gemfile:

    gem 'yahoo-group-data'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yahoo-group-data

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

*pull requests with tests are more likely to be accepted*

### Testing

Rather than distribute a load of Yahoo's HTML pages with the gem there's a rake task to get the ones that are needed. Run:

	$ rake fetch_yahoo_pages

after that:

	$ rake test

Because of the dynamic nature of Yahoo groups it's quite possible that the number of members a group has in groups.yml will have diverged with the number of members in reality when you pull down the pages using "rake fetch_yahoo_pages". If you see any of these divergences just update groups.yml appropriately.

### If you find a group the gem fails on

Tell me about it, or (in preference) update the gem (Hint: start by adding an entry to the groups.yml file), see contributing instructions above.

## Authors

* Will Jessop (will@willj.net)
