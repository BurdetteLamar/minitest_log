### Attributes

Put attributes onto a section by calling ```MinitestLog#section``` with hash arguments.

Each name/value pair in the hash becomes an attribute in the log section header.

The section name is always the first argument, but otherwise hashes can be anywhere among the arguments.

@[ruby](example.rb)

The log:

@[xml](log.xml)
