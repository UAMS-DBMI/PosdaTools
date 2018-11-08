from box import Box
import sys

class Parser(object):
    def __init__(self, arguments, purpose, help):
        self.arguments = arguments
        self.purpose = purpose
        self.help = help

    def usage(self):
        args = [a.name.upper() for a in self.arguments]
        print(self.purpose, '\n')
        print(f"Usage: {sys.argv[0]} " + ' '.join(args))
        for arg in self.arguments:
            print(f"  {arg.name}: {arg.desc}")


    def parse(self):
        # TODO: build an arg parser???

        if len(sys.argv) < len(self.arguments) + 1:
            self.usage()
            if '-h' in sys.argv:
                print()
                print(self.help)
            sys.exit(1)

        # assign the args
        args_list = Box()
        for name, value in zip([a.name for a in self.arguments], sys.argv[1:]):
            args_list[name] = value

        return args_list

class Argument(object):
    def __init__(self, name, desc, type_):
        self.name = name
        self.desc = desc

    def __str__(self):
        return f"<Argument: '{self.name}'>"

    def __unicode__(self):
        return self.__str__()

    def __repr__(self):
        return self.__str__()

class CustomArgument(Argument):
    def __init__(self, name, desc="", type_=None):
        super(CustomArgument, self).__init__(name, desc, type_)

    def __str__(self):
        return f"<Custom: '{self.name}'>"


Presets = Box(dict(background_id=Argument("background_id", "Database ID of this invocation", int),
                   description=Argument("description", "A simple description", str),
                   notify=Argument("notify", "Email address to notify when complete", str)))
