### Rescue

Specify rescuing for a section by calling ```MinitestLog#section``` with the symbol ```:rescue```.

Any exception raised during the section's execution will be rescued and logged.  Such an exception terminates the *section*, but not the *test*.

(An unrescued exception does terminate the test.)

@[ruby](example.rb)

The log:

@[xml](log.xml)
