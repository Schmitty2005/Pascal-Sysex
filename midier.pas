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
    posMidiTrack : Pbyte;//^byte;
    midiHeader: TMIDIHeader;
    midiFileName: string;
    midiFileBytes: array of byte;
    fileTrackPointers: array of PTTrackChunk;
    procedure loadMIDIfile(fnam: string);
    function getFirstTrackPos: Pointer;
    procedure setTrackPointers;
    function getNextTrackPos(previousTrack: PTTrackChunk): PTTrackChunk;
  public
    procedure getHeader;
    property filename: string read midiFileName write loadMIDIfile;
    function viewTrack (TrackNumber : Word) : String;
  end;

implementation

function Tmidier.viewTrack (TrackNumber : Word) : String;
type
  PTrackPos = Pbyte;
var
  tLength : word;
  TrackNumPointer : Pbyte;
  LengthPointer : PDword;
  x : Qword;
begin
  x:=0;
  TrackNumPointer := Pbyte(filetrackpointers[TrackNumber -1]);
  posMidiTrack := Pbyte(TrackNumPointer)+8;//skip header info
  LengthPointer := (Pointer(TrackNUmPointer))+4;
  // would tLength = BEtoN((Pword(TrackNUmPointer)+5)^); //work ?
  tLength := BEtoN(LengthPointer^);
  writeln (format('X: %d Header : %p , Length : %d', [x, TrackNumPointer, tLength]));
  // test routine for position of header pointer
  repeat
      posMidiTrack := posMidiTrack + (x);
      writeln (format ('X: %d    Position : %p', [x, posMidiTrack]));
  //start to breakdown MIDI messages
  //NOT COMPLETE !
      case (posMIDITrack^) of
        255 : write (posMIDITrack^);

      else
      posMIDItrack := Pbyte(posMIDITrack) + 1;

      end;
      inc(x);
      //end;
   until  x = tLength-2;
  result :='';
end;

procedure Tmidier.getHeader;
var
  PmidiHeader: ^TMIDIHeader;
begin
  PmidiHeader := Pointer(midiFileBytes);// Dynamic arrays are pointers.
  midiHeader.chunkSize := BEtoN(PmidiHeader^.chunkSize);
  midiHeader.formatType := BEtoN(PmidiHeader^.formatType);
  midiHeader.numTracks := BEtoN(PmidiHeader^.numTracks);
end;

procedure Tmidier.setTrackPointers;
var
  x: Qword;
begin
  x := 1;
  setlength(self.fileTrackPointers, (self.midiHeader.numTracks) + 1);
  fileTrackPointers[0] := self.GetFirstTrackPos;
  if (x <= (self.midiHeader.numTracks)) then
  begin
    fileTrackPointers[x] := self.getNextTrackPos(fileTrackPointers[x - 1]);
    Inc(x);
  end;

end;

function readTrackSize(blockStart: PTTrackChunk): Qword; inline;
begin
  Result := BEtoN(blockstart^.chunkSize);
end;

function Tmidier.getFirstTrackPos: Pointer; inline;
begin
  Result := Pointer(midiFileBytes) + sizeof(TMIDIHeader);
end;

function Tmidier.getNextTrackPos(previousTrack: PTTrackChunk): PTTrackChunk;
begin
  try
    Result := (Pointer(previousTrack) + (BEtoN(previousTrack^.chunkSize)) + 8);
  except
    writeln('ERROR');
  end;
end;

procedure Tmidier.loadMIDIfile(fnam: string);
var
  fstream: TFileStream;
  n: longint;
  Data: array of byte;
begin
  fstream := TFileStream.Create(fnam, fmOpenRead or fmShareDenyWrite);
  Data := nil;
  try
    n := fstream.Size;
    SetLength(Data, n);
    fstream.Read(Data[0], n);
  finally
    fstream.Free;
  end;
  midiFileBytes := Data;
  self.getheader;
  self.setTrackPointers;
end;


end.
