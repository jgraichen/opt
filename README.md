# Opt

An option parsing library.

## Installation

Add this line to your application's Gemfile:

    gem 'opt'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opt

## Usage

Simply specify your options:

```ruby
opt = Opt.new
opt.option '--help, -h'
opt.option '--version, -v'

result = opt.parse %w(-h)
result.help? #=> true
result.version? #=> nil
```

You can also specify subcommands, the number of arguments for a switch or a text option. You can further specify a custom name with the opts hash, otherwise the name of the first switch will be used.

```ruby
opt = Opt.new
opt.command 'merge' do |cmd|
  cmd.option '--out, -O', nargs: 1
  cmd.option 'file', name: :files, nargs: '+'
end

result = opt.parse %w(merge --out out.txt file1.txt file2.txt)
result.out #=> "out.txt"
result.files #=> ["file1.txt", "file2.txt"]
```

Different styles are supported:

```ruby
opt = Opt.new
opt.option '--level, -l', nargs: 1

opt.parse(%w(--level 5)).level #=> "5"
opt.parse(%w(--level=5)).level #=> "5"
opt.parse(%w(-l 5)).level #=> "5"
opt.parse(%w(-l5)).level #=> "5"
```

See API documentation and specs for more examples and configuration option.

## Contributing

1. Fork it (http://github.com/jgraichen/opt/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add specs so that I do not break your feature later.
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## License

Copyright (C) 2014 Jan Graichen

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
