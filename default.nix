{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;

  transpileBF = code:
    with lib; let
      validSymbols = ["[" "]" "+" "-" ">" "<" "." ","];

      tokens =
        builtins.filter
        (x: elem x validSymbols)
        (splitString "" code);

      translateToken = token:
        if token == "["
        then "  while (tape[cell]) {\n"
        else if token == "]"
        then "  }\n"
        else if token == "+"
        then "  tape[cell] += 1;\n"
        else if token == "-"
        then "  tape[cell] -= 1;\n"
        else if token == ">"
        then "  cell += 1;\n"
        else if token == "<"
        then "  cell -= 1;\n"
        else if token == "."
        then "  putchar(tape[cell]);\n"
        else if token == ","
        then "  tape[cell] = getchar();\n"
        else abort "Invalid character detected";

      cSource = ''
        extern int putchar(int);
        extern char getchar();

        char tape[30000];

        int cell = 0;
        int main() {
        ${concatStringsSep "\n" (map translateToken tokens)}
        }
      '';

      forwardJumps = count (x: x == "[") tokens;
      backwardJumps = count (x: x == "]") tokens;
    in
      if (forwardJumps != backwardJumps)
      then abort "${fowardJumps} forward jump(s) vs. ${backwardJumps} backward jump(s)"
      else cSource;
in {
  writeBFBin = name: code: pkgs.writeCBin name (transpileBF code);
}
