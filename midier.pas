unit midier;

{$mode Delphi}

interface

uses
  Classes, SysUtils;

Type
  Tmidier = class
    private
      midiFileName : String;
      midiFileBytes : array of Byte;
      procedure loadSysex(fnam: string);
    public
      property filename : String read midiFileName;
  end;

implementation

procedure Tmidier.loadSysex(fnam: string);
var
  fstream: TFileStream;
  n: longint;
  Data: array of byte;
begin
  fstream := TFileStream.Create(fnam, fmOpenRead or fmShareDenyWrite);
  try
    n := fstream.Size;
    SetLength(Data, n);
    fstream.Read(Data[1], n);
  finally
    fstream.Free;
  end;
  midiFileBytes := Data;
end;


end.

