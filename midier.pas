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

  Tmidier = class
  private
    midiHeader: TMIDIHeader;
    midiFileName: string;
    midiFileBytes: array of byte;
    m_pointer: Pointer;
    procedure loadMIDIfile(fnam: string);
  public
    procedure getHeader;
    property filename: string read midiFileName write loadMIDIfile;
  end;

implementation

procedure Tmidier.getHeader;
var
  PmidiHeader: ^TMIDIHeader;
  outputHeader: TmidiHeader;
begin
  PmidiHeader := Pointer(midiFileBytes);// Dynamic arrays are pointers.
  outputHeader := PmidiHeader^;
  midiHeader.chunkSize := BEtoN(outputheader.chunkSize);
  midiHeader.formatType := BEtoN(outputheader.formatType);
  midiHeader.numTracks := BEtoN(outputHeader.numTracks);
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
