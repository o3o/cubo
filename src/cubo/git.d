module cubo.git;

import std.json : JSONValue;
import std.experimental.logger;


void clone(JSONValue json) {
   import std.array : join;
   import std.file : exists, mkdirRecurse, rmdirRecurse;
   import std.process : execute;
   import std.path : buildPath;
   import cubo.util : isValidDep, getVersion, REPO;

   if ("dependencies" in json) {
      JSONValue[string] dep = json["dependencies"].get!(JSONValue[string]);
      foreach (name, value; dep) {
         if (isValidDep(value)) {
            string ver = value.getVersion;
            string f = buildPath(REPO, name ~ "-" ~ ver);
            string url = value["url"].get!string;

            if (!exists(f) && isGit(url)) {
               f.mkdirRecurse;

               string[] cmd = getCloneCmd(url, ver, f);
               tracef("Clone %s version %s", name, ver);

               auto reply = execute(cmd);
               if (reply.status != 0) {
                  error("Failed\n", reply.output);
               } else {
                  info("Clone Successful");
               }
            } else {
               tracef("%s already downloaded", f);
            }
         }
      }
   }
}

bool isGit(string url) {
   import std.algorithm.searching : startsWith;
   return url.startsWith("git") || url.startsWith("https");
}


string[] getCloneCmd(string url, string branch, string folder) {
   string[] a = ["git", "clone", "--depth", "1"];
   a ~= "--branch";
   a ~= "v" ~ branch;
   a ~= url;
   a ~= folder;

   return a;
}

void cleanRepo() {
   import std.file : rmdirRecurse;
   import cubo.util : REPO;

   REPO.rmdirRecurse;
}
