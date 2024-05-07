//Using Website : https://www.codeconvert.ai/c-to-pascal-converter  to 
{$MODE DELPHI}
procedure WriteVarLen(value: longint);
var
  buffer: longint;
  outfile : Qword;
  infile : Qword;
begin
  outfile := 0;
  buffer := value and $7F;
  while (value shr 7) > 0 do
  begin
    buffer := (buffer shl 8) or $80;
    buffer := buffer + (value and $7F);
    value := value shr 7;
  end;
  while true do
  begin
    write(outfile, chr(buffer));
    if (buffer and $80) = 0 then
      break
    else
      buffer := buffer shr 8;
  end;
end;

function ReadVarLen (infile : Qword) : int64;
var
  value: int64;
  c: byte;
 // infile : Qword;
begin
  //infile := 0;
  value := (infile);
  if (value and $80) <> 0 then
  begin
    value := value and $7F;
    repeat
      c := (infile);
      value := (value shl 7) + (c and $7F);
    until (c and $80) = 0;
  end;
  Result := value;
end;

BEGIN
write('Compiled! .....');
write (Qword(WriteVarLen(257)));
END.

