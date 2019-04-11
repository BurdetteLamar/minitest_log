### Potpourri

So far, examples for method ```section``` have emphasized one thing at a time.

A call to method ```section``` begins always with the section name, but after that it can have any number and any types of arguments.

Note that:

- Multiple string arguments are concatenated, left to right, to form one string in the log.
- Each hash argument's name/value pairs are used to form attributes in the log.
- Symbols ```:timestamp```, ```:duration```, and ```:rescue``` may appear anywhere among the arguments.  Duplicates are ignored.

@[ruby](example.rb)

@[xml](log.xml)

