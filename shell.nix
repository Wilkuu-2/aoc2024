
with (import <nixpkgs> {});
let
  libs = [
   ];
in 
mkShell {
      packages = [lua lua-language-server luajit];
      buildInputs = libs;
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libs;
}
