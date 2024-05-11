{$MODE DELPHI}
program sysblock;
{
==============================================
A testing ground for the sysexer.pas methods
==============================================
}
uses
  SysUtils,
  sysexer, midiUnits, midier;

var
  blocktest: Tblockse;
  block: Tsys;
  outpos: Tblocks;
  x: Qword;
  z: byte;
  y : Qword;
  doubleMidi : Tmidier;

  sysfile: Tsysex;

  function countblocks(Count: Tsys): Tblocks; forward;

  function builder(dis, times: qword): Tsys;
    //For building faux sysex byte array for testing only!
  var
    build: Tsys;
    x, y: Qword;
    //z : Byte;
  begin
    setLength(build, ((dis * times) + 2));
    x := 0;
    y := 1;// must remain 1 to avoid multiply by zero!
    while (y < (times + 1)) do
    begin
      build[x] := 240;
      x := x + 1;
      while (x <= (dis * (y))) do
      begin
        build[x] := 37;
        x := x + 1;
      end;
      build[(x)] := 247;
      x := x + 1;
      y := y + 1;
    end;
    build[x - 1] := 247;
    builder := build;
  end;

  function countblocks(Count: Tsys): Tblocks;
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
    if (y <> w) then writeln('Block count error!')
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

    Result := output;
  end;



begin

  //build fake sysex block
  block := builder(255, 512);


  z := 0;
  outpos := countblocks(block);
  writeln('OUTPUT of fake sysex :    ');

  {
  x := 0;
  for blocktest in outpos do
  begin
    Write('#:');
    Write(x);
    Write(' ');
    Write('Start: ');
    writeln(blocktest.startpos);
    Write('         End : ');
    writeln(blocktest.endpos);
    //writeln();
    x := x + 1;
  end;
   }

  sysfile := Tsysex.Create();
  //sysfile.loadSysex('sysextest.syx');
  sysfile.filename := 'sysextest.syx';

  //sysfile.setBlocks;
  //sysfile.blockTextSlice(3 ,12,24); //Should output SY-85 Block Type 0065VC
  Write('BlockTextSlice Called...... ');
  writeln(sysfile.blockTextslice(3, 12, 24));
  Write('File Name : ');
  writeln(sysfile.filename);

  //Write('Size of sysex file : ');
  writeln(sysfile.sysex_size);
 /// //('Block to Hex called.....');
 writeln(sysfile.blocktohex(0));
//writeln(sysfile.sysexBlocks);
{
y:=0;
  while (y<sysfile.sysexBlocks)  do
  begin
    writeln('                       Y: )' + y.toString);
   write ( sysfile.blocktohex(y));
   inc(y);
  end;
 }
  writeln( sysfile.blockchecksumvalue(0)) ;
  sysfile.free;
  doublemidi:= Tmidier.create();

  doublemidi.filename := 'rushmidi.mid';


  //doublemidi.setBytes(65536);
end.
