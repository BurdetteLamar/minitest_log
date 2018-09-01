### Duration

Put a duration onto a section by calling ```MinitestLog#section``` with the symbol ```:duration```.  The log will then include the execution duration for the section.

The section name is always the first argument, but otherwise the symbol can be anywhere among the arguments.

@[ruby](example.rb)

The log:

@[xml](log.xml)
