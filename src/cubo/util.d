module cubo.util;

import std.json : JSONValue;
import std.experimental.logger;

enum REPO = ".cubo";

bool isValidDep(JSONValue v) {
   return ("version" in v) && ("url" in v);
}
unittest {
   import std.json : parseJSON;

   immutable j0 = parseJSON(`{ "name": "Depot", "description": "A Depot Library" }`);
   assert(!isValidDep(j0));
   assert(!isValidDep(parseJSON(`{ "version": "42", "description": "A Depot Library" }`)));
   assert(isValidDep(parseJSON(`{ "version": "42", "url": "A Depot Library" }`)));
}

string getVersion(JSONValue json) {
   import std.string : startsWith;
   if ("version" in json) {
      string ver = json["version"].get!string;
      if (ver.startsWith("v")) {
         return ver[1 .. $];
      } else {
         return ver;
      }
   } else {
      throw new Exception("No version");
   }
}

string getTargetType(JSONValue json) {
   if ("targetType" in json) {
      return  json["targetType"].get!string;
   } else {
      return "exe";
   }
}

string getTargetPath(JSONValue json) {
   if ("targetPath" in json) {
      return json["targetPath"].get!string;
   } else {
      return "bin";
   }
}

string getTargetName(JSONValue json) {
   import std.path : buildPath, setExtension;
   if ("targetName" in json) {
      return buildPath(json.getTargetPath, json["targetName"].get!string);
   } else {
      return buildPath(json.getTargetPath, json["name"].get!string).setExtension(json.getTargetType == "library" ? "dll" : "exe");
   }
}

unittest {
   import std.json : parseJSON;
   assert(getTargetName(parseJSON(`{ "targetPath": "cacc", "targetName": "cul"}`)) == "cacc/cul");
   assert(getTargetName(parseJSON(`{  "targetName": "cul"}`)) == "bin/cul");
   assert(getTargetName(parseJSON(`{ "name": "piss", "targetType": "library"}`)) == "bin/piss.dll");
   assert(getTargetName(parseJSON(`{ "name": "piss", "targetPath": ".", "targetType": "library"}`)) == "./piss.dll");
}

string[] getRecurse(JSONValue json) {
   import std.path : buildPath;
   string[] list;
   if ("dependencies" in json) {
      JSONValue[string] dep = json["dependencies"].get!(JSONValue[string]);
      foreach (name, value; dep) {
         string ver = value.getVersion;
         string f = buildPath(REPO, name ~ "-" ~ ver, "src", name, "*.cs");
         tracef("folder: %s", f);
         list ~= f;
      }
   }
   return list;
}

string[] getSrc(string dir, string pattern = "*.cs") {
   import std.file : dirEntries, exists, isDir, SpanMode;

   string[] list;
   if (exists(dir) && dir.isDir) {
      auto files = dirEntries(dir, pattern, SpanMode.depth);
      foreach (s; files) {
         tracef("cs file: %s", s.name);
         if (s.isFile) {
            list ~= s.name;
         }
      }
   }
   return list;
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
