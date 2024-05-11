{$mode Delphi}
unit midier;

interface

uses
  Classes, SysUtils;

type
  Tmidier = class
  private
    midiFileName: string;
    midiFileBytes: array of byte;
    procedure loadSysex(fnam: string);
  public
    property filename: string read midiFileName;
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
