{$MODE DELPHI}
unit sysexer;

interface

uses SysUtils, Classes;//, strutils;

type
  Tsys = array of byte;

  TblockSE = record
    startPos, endPos: longint;
  end;
  Tblocks = array of TblockSE;
  Tpoints = array[1..2] of Qword;

  Tsysex = class
  private
    sysex_filename: string;
    sysex_blocks: Tblocks;
    sysarray: Tsys;
    single: byte;
    function get_sysex_size(): Qword;
    function get_filename: string;
    procedure set_filename(fname: string);
    function get_block(blockNumber: Qword): Tsys;
    function get_msb_lsb_value(msb, lsb: byte): word;
  public
    blockPoints: Tblocks;
    procedure setBlocks;
    function countblocks(Count: Tsys): Tblocks;
    function blockTextSlice(block: Qword; startpos, endpos: Qword): string;
    function blockToHex(block: Qword): string;
    procedure loadSysex(fnam: string);
    property get_sysex_blocks: Tblocks read sysex_blocks;

  published
    property sysex_size: Qword read get_sysex_size;
    property filename: string read sysex_filename write set_filename;
  end;


implementation

function Tsysex.get_msb_lsb_value(msb, lsb: byte): word;
begin
  Result := (msb * 128) + lsb;
end;

function Tsysex.get_block(blockNumber: Qword): Tsys;
var
  blockPoints: TblockSE;
  blockData: Tsys;
  output: Tsys;
  startpos, endpos, x, y: Qword;
begin
  blockPoints := sysex_blocks[blockNumber];
  startpos := blockPoints.startpos;
  endpos := blockPoints.endpos;
  setLength(output, ((endpos - startpos) + 1));
  y := 0;
  for x := startpos to (endpos + 1) do
  begin
    output[y] := sysarray[x];
    y := y + 1;
  end;
  Result := output;
end;

function Tsysex.get_filename: string;
begin
  Result := sysex_filename;
end;

procedure Tsysex.set_filename(fname: string);
begin
  sysex_filename := fname;
  loadsysex(fname);
  exit();
end;

function Tsysex.get_sysex_size(): Qword;
begin
  Result := length(sysarray);
end;

function Tsysex.blockToHex(block: Qword): string;
const
  columnSpace = '     ';
  hexSpace = '  ';
var
  output, asciiOut: string;
  outbyte: byte;
  tempblock: Tsys;
  y, z: Qword;
begin
  output := '';
  asciiout := columnSpace;
  tempblock := get_block(block);
  y := 0;
  for outbyte in tempblock do
  begin
    output := output + (IntToHEx(outbyte)+ hexSpace);
    if ((outbyte  <32) or (outbyte > 128)) then
    asciiout := asciiout + '.'
    else
    asciiout := asciiout + char(outbyte);
    y := y + 1;
    //Write(IntToHex(outbyte));
    //Write(' ');

    if ((y mod 16) = 0) and (y <> 0) then
      begin
        output := output + asciiOut + slineBreak;
        asciiOut :=columnSpace;
      end;
  writeln(output);
  Result := output;
  end;
end;

function Tsysex.blockTextSlice(block: Qword; startpos, endpos: Qword): string;
var
  textout: string;
  blockSys: Tsys;
  x: Qword;
begin
  textout := '';
  x := startpos;
  // writeln();
  //writeln('Block Text Called...');
  while x <= endpos do
  begin
    textout := textout + char(sysarray[x]);
    Write(char(sysarray[x]));
    x := x + 1;
  end;
  Result := textout;
end;

function Tsysex.countblocks(Count: Tsys): Tblocks;
var
  output: Tblocks;
  w, x, y, z: Qword;
begin
  w := 0;
  y := 0;
  z := high(Count);
  w := 0;
  for x := 0 to z do
  begin
    if Count[x] = 240 then w := w + 1;
    if Count[x] = 247 then y := y + 1;
  end;
  if ((y + 1) <> w) then writeln('Block count error!')
  else
    setlength(output, w);

  y := 0;
  for x := 0 to (z) do
  begin
    if Count[x] = 240 then output[y].startPos := x;
    if Count[x] = 247 then
    begin
      output[y].endpos := x;
      y := y + 1;
      w := w + 1;
    end;
  end;
  Write('W :');
  writeln(w);

  setlength(Result, w);

  sysex_blocks := output;
  Result := output;
end;

procedure Tsysex.setBlocks();
begin
  writeln('setBlocks called....');
  writeln(length(sysarray));
  for single in sysarray do
  begin

    Write(single);
    Write(',');
  end;

end;

procedure Tsysex.loadSysex(fnam: string);
var
  fstream: TFileStream;
  n: longint;
  Data: array of byte;
begin
  fstream := TFileStream.Create(fnam, fmOpenRead or fmShareDenyWrite);
  try
    n := fstream.Size;
    SetLength(Data, n);
    fstream.Read(Data[1], n);//this line maybe needs work!
  finally
    fstream.Free;
  end;
  sysarray := Data;
  blockpoints := countblocks(sysarray);
end;


initialization
  begin

  end;

finalization
  begin

  end;
end.
