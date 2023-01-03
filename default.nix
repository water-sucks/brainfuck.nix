{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;

  transpileBF = code:
    with lib; let
      validSymbols = ["[" "]" "+" "-" ">" "<" "." ","];

      rawTokens =
        builtins.filter
        (x: elem x validSymbols)
        (splitString "" code);

      tokens = let
        count = list: c:
          if length list == 0
          then []
          else if length list == 1
          then [
            {
              symbol = head list;
              repeat = "1";
            }
          ]
          else let
            x = elemAt list 0;
            y = elemAt list 1;
            xs = drop 2 list;
          in
            if x == y
            then count ([y] ++ xs) (c + 1)
            else
              [
                {
                  symbol = x;
                  repeat = toString c;
                }
              ]
              ++ (count ([y] ++ xs) 1);
      in
        count rawTokens 1;

      translateToken = token: let
        repeat = string: num: concatStringsSep "" (genList (_: string) (toInt num));
      in
        if token.symbol == "["
        then repeat "  while (tape[cell]) {\n" token.repeat
        else if token.symbol == "]"
        then repeat "  }\n" token.repeat
        else if token.symbol == "+"
        then "  tape[cell] += ${token.repeat};\n"
        else if token.symbol == "-"
        then "  tape[cell] -= ${token.repeat};\n"
        else if token.symbol == ">"
        then "  cell += ${token.repeat};\n"
        else if token.symbol == "<"
        then "  cell -= ${token.repeat};\n"
        else if token.symbol == "."
        then repeat "  putchar(tape[cell]);\n" token.repeat
        else if token.symbol == ","
        then repeat "  tape[cell] = getchar();\n" token.repeat
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

      forwardJumps = count (x: x == "[") rawTokens;
      backwardJumps = count (x: x == "]") rawTokens;
    in
      if (forwardJumps != backwardJumps)
      then abort "${fowardJumps} forward jump(s) vs. ${backwardJumps} backward jump(s)"
      else cSource;
in {
  writeBFBin = name: code: pkgs.writeCBin name (transpileBF code);
}
