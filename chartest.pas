{$MODE DELPHI}
{$codepage utf-8}

Program chartest;

Uses sysutils;

Const 
  TOP_HORIZONTAL : string = #$02550;

Var 
  x : word;

Begin
  x := 0;
  While x < 80 Do
    Begin
      write(TOP_HORIZONTAL);
      inc(x);
    End;
End.
