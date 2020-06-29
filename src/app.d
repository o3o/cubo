module app;

import std.stdio : writefln, writeln, File;
import std.experimental.logger;
import std.json : JSONValue;
import std.getopt;
import cubo.git;
import cubo.ninja : makeNinja;

struct Option {
   string file = "ninja";
}

void main(string[] args) {
   bool verbose;
   bool clean;
   bool dry;
   string generate = "ninja";
   string proxyFile = "cubo.json";
   Option c;

   auto opt = getopt(args, "verbose|v", "Verbose", &verbose,
         "clean|c", "Delete package directory", &clean,
         "dry-run|n", "Just print", &dry,
         "generate|g", "Generate file (mak|ninja|tup)", &generate
         );
   if (verbose) {
      globalLogLevel(LogLevel.trace);
   } else {
      globalLogLevel(LogLevel.info);
   }
   if (opt.helpWanted) {
      defaultGetoptPrinter("cubo", opt.options);
      //help;
   } else {
      JSONValue j = makeJson(proxyFile);
      trace(j);
      if (dry) {
         dryRun(j);
      } else {
         if (clean) {
            cleanRepo();
         }
         clone(j);
      }

      if (c.file == "ninja") {
         makeNinja(j);
         /+
      } else if (c.file == "mak") {
         makeMakefile(j, c);
      } else if (c.file == "tup") {
         makeTup(j, c);
         +/
      }
   }
}

JSONValue makeJson(string fn) {
   import std.file : readText;
   import std.json : parseJSON;
   string depJ = readText(fn);
   return parseJSON(depJ);
}

void dryRun(JSONValue j) {
   if ("dependencies" in j) {
      JSONValue[string] dep = j["dependencies"].get!(JSONValue[string]);
      foreach (k,v; dep) {
         writefln("key %s values %s", k, v);
      }
   }
}

unittest {
   import std.json : parseJSON;
   string s0 =
      `{
         "name": "Depot",
         "description": "A Depot Library"
      } `;
   immutable j0 = parseJSON(s0);
   dryRun(j0);
   string s1 =
      `{
         "name": "Depot",
         "description": "A Depot Library",
         "dependencies" : {}
      } `;
   immutable j1 = parseJSON(s1);
   dryRun(j1);
}
