{$MODE DELPHI}
{$codepage utf-8}

program chartest;

uses sysutils;

const
   TOP_HORIZONTAL :string = #$02550;
var
x : word;

begin
x:=0;
while x < 80 do
begin


write(TOP_HORIZONTAL);
inc(x);
end;

end.

