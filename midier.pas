{$mode Delphi}
unit midier;

interface

uses
  Classes, SysUtils;

type
  TMIDIHeader = bitpacked record
    chunkID: array[0..3] of char;  //Always 'MThd' 0x4D546864
    chunkSize: Dword;
    formatType: word;              // 0, 1, OR 2
    numTracks: word;
    timeDivision: word;
  end;

  TTrackChunk = bitpacked record
    chunkID: array [0..3] of char; //Always 'MTrk' 0x4D54726B
    chunkSize: Dword;
  end;

  PTTrackChunk = ^TTrackChunk;
  PTMIDIHeader = ^TMIDIHeader;

  Tmidier = class
  private
    midiHeader: TMIDIHeader;
    midiFileName: string;
    midiFileBytes: array of byte;
    procedure loadMIDIfile(fnam: string);

  public
    procedure getHeader;
    property filename: string read midiFileName write loadMIDIfile;
  end;

implementation

procedure Tmidier.getHeader;
var
  PmidiHeader: ^TMIDIHeader;
begin
  PmidiHeader := Pointer(midiFileBytes);// Dynamic arrays are pointers.
  midiHeader.chunkSize := BEtoN(PmidiHeader^.chunkSize);
  midiHeader.formatType := BEtoN(PmidiHeader^.formatType);
  midiHeader.numTracks := BEtoN(PmidiHeader^.numTracks);
end;

procedure Tmidier.loadMIDIfile(fnam: string);
var
  fstream: TFileStream;
  n: longint;
  Data: array of byte;
begin
  fstream := TFileStream.Create(fnam, fmOpenRead or fmShareDenyWrite);
  try
    n := fstream.Size;
    SetLength(Data, n);
    fstream.Read(Data[0], n);
  finally
    fstream.Free;
  end;
  midiFileBytes := Data;
end;


end.
