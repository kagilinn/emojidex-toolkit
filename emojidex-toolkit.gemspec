Gem::Specification.new do |s|
  s.name        = 'emojidex-toolkit'
  s.version     = '0.0.2'
  s.license     = "GNU LGPL v3"
  s.summary     = "Ruby Toolkit for emojidex"
  s.description = "emojidex toolkit provides converters, search and lookup, listing and caching functionality and user info (favorites/etc)."
  s.authors     = ["Rei Kagetsuki"]
  s.email       = 'zero@genshin.org'
  s.files        = `git ls-files`.split("\n")
  s.homepage    = 'http://emojidex.com/dev'

  s.add_dependency 'rsvg2'
  s.add_dependency 'rmagick'
  s.add_dependency 'rapngasm'
  s.add_dependency 'ruby-filemagic'
end
