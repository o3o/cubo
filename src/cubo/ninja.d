module cubo.ninja;

import std.json : JSONValue;
import std.experimental.logger;
import cubo.util;

void makeNinja(JSONValue json) {
   import std.stdio : writefln, writeln, File;

   auto dest = File("build.ninja", "w");

   dest.writefln("name = %s", json.getTargetName);
   dest.writefln("target = %s", json.getTargetType);

   if ("sdk" in json) {
      dest.writefln("sdk = %s", json["sdk"].get!string);
   } else {
      dest.writefln("sdk = 4.7");
   }

   dest.writefln("refs = %-(-r:%s %)",  getRefs(json));
   dest.writefln("csflag = -sdk:$sdk -target:$target -lib:%s", json.getTargetPath);

   dest.writefln("recurse = %-(-recurse:%s %)", getRecurse(json));
   string[] src =  getSrc("./src");
   dest.writeln("rule compile");
   dest.writeln("   command = mcs $csflag $refs -out:$out $recurse $in");
   dest.writefln("build $name: compile %-(%s %)", src);

   JSONValue ut= getUnitTest(json);
   if (!ut.isNull) {
      dest.writeln();
      dest.writefln("name_test = %s", ut.getTargetName);
      dest.writefln("refs_test = %-(-r:%s %)",  getRefs(ut));
      dest.writefln("csflag_test = -sdk:$sdk -target:exe -lib:%s", json.getTargetPath);
      dest.writeln("recurse_test = -recurse:./tests/*.cs");
      dest.writeln("rule compile-test");
      dest.writeln("   command = mcs $csflag_test $refs_test $refs -out:$out $recurse $recurse_test $in");
      dest.writeln("rule run");
      dest.writeln("   command = mono $in");
      dest.writeln();
      dest.writeln("build build-test: phony $name_test");
      dest.writefln("build $name_test: compile-test %-(%s %)", src);
      dest.writeln("build test: run $name_test");
   }


   dest.writeln();
   dest.writeln("rule tagscmd");
   dest.writeln("   command = ctags $in");
   dest.writeln();
   dest.writefln("build tags: tagscmd %-(%s %)", src);
}

string[] getRefs(JSONValue json) {
   string[] list;
   if ("libs" in json) {
      JSONValue[] libs = json["libs"].get!(JSONValue[]);
      foreach (n; libs) {
         list ~= n.str;
      }
   }
   return list;
}

unittest {
   import std.json : parseJSON;

   string[] r = getRefs(parseJSON(`{ "libs": ["a", "b", "c"]}`));
   assert(r[0] == "a");
}

JSONValue getUnitTest(JSONValue json) {
   JSONValue ut;
   if ("configurations" in json) {
      JSONValue[] conf = json["configurations"].get!(JSONValue[]);
      foreach (value; conf) {
         if (value["name"].get!string == "unittest") {
            return value;
         }
      }
   }
   return ut;
}

unittest {
   import std.json : parseJSON;

   JSONValue j = getUnitTest(parseJSON(`{ "libs": ["a", "b", "c"]}`));
   assert(j.isNull);
   JSONValue ut = getUnitTest(parseJSON(`{
            "configurations": [
            {
            "name": "unittest",
            "targetType": "exe",
            "targetPath": "bin",
            "sdk" : "4.7"
            }
            ]

            }`));
   assert(!ut.isNull);
}

