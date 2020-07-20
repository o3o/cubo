module cubo.make;

import std.json : JSONValue;
import std.experimental.logger;
import cubo.util;

void makeMakefile(JSONValue json) {
   import std.stdio : writefln, writeln, File;

   auto dest = File("makefile", "w");
   dest.writefln("NAME = %s", json.getTargetName);
   dest.writefln("TARGET = %s", json.getTargetType);
   if ("sdk" in json) {
      dest.writefln("SDK = %s", json["sdk"].get!string);
   } else {
      dest.writefln("SDK = 4.7");
   }

   dest.writefln("REFS = %-(-r:%s %)",  getRefs(json));
   dest.writefln("CSFLAG = -sdk:$(SDK) -target:$(TARGET) -lib:%s", json.getTargetPath);
   dest.writefln("RECURSE = %-(-recurse:%s %)", getRecurse(json));

   string[] src = getSrc("./src");
   dest.writefln("SRC = %-(%s %)", src);
   dest.writeln();

   dest.writeln("$(NAME): $(SRC)");
   dest.writeln("\tmcs $(CSFLAG) $(REFS) -o:$@ $(SRC)");
   dest.writeln();

   JSONValue ut = getUnitTest(json);
   if (!ut.isNull) {
      dest.writeln();
      dest.writefln("NAME_TEST = %s", ut.getTargetName);
      dest.writefln("REFS_TEST = %-(-r:%s %)",  getRefs(ut));
      dest.writefln("CSFLAG_TEST = -sdk:$(SDK) -target:exe -lib:%s", json.getTargetPath);
      dest.writeln("RECURSE_TEST = -recurse:./tests/*.cs");
      dest.writeln();

      dest.writeln("build-test: $(NAME_TEST)");
      dest.writeln("test: $(NAME_TEST)");
      dest.writeln("\tmono $(NAME_TEST)");
      dest.writeln();

      dest.writeln("$(NAME_TEST): $(SRC)");
      dest.writeln("\tmcs $(CSFLAG_TEST) $(REFS_TEST) $(REFS) -out:$@ $(RECURSE) $(RECURSE_TEST)");
      dest.writeln();
   }
   dest.writeln("tags: $(SRC)");
   dest.writeln("\tctags $^");

   dest.writeln("clean:");
   dest.writeln("\t-rm -f $(NAME)");
   dest.writeln("\t-rm -f $(NAME_TEST)");
   dest.writefln("\t-rm -f %s/*.mdb", getTargetPath(json));
}
