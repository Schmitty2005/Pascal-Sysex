{$mode Delphi}
{$T-}
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
    posMidiTrack: pbyte;//^byte;
    midiHeader: TMIDIHeader;
    midiFileName: string;
    midiFileBytes: array of byte;
    fileTrackPointers: array of PTTrackChunk;
    procedure loadMIDIfile(fnam: string);
    function getFirstTrackPos: Pointer;
    procedure setTrackPointers;
    function getNextTrackPos(previousTrack: PTTrackChunk): PTTrackChunk;
    function vblDecode(bytePoint: Pointer): longword; inline;
  public
    procedure getHeader;
    property filename: string read midiFileName write loadMIDIfile;
    function viewTrack(TrackNumber: word): string;
  end;

implementation

function Tmidier.viewTrack(TrackNumber: word): string;
var
  tLength: word;
  TrackNumPointer: pbyte;
  LengthPointer: PDword;
  x: Qword;
  delta: longword;
  eventLength: longword;
  eventType: byte;


  function vblDecode(bytePoint: Pointer): longword; inline;
  var
    w: ^byte;
    x: byte;
    output: longword;
  begin
    // $81 and $7F should be 255
    // $82 , $80, and $00 = 32768
    x := 0;
    output := 0;
    repeat
      w := bytePoint + x;
      Inc(x);
      output := ((output shl 7) or ((w^ and $7F)));
    until (byte(w^) and $80) = 0;
    //remember to set class pointer here
    Inc(posMIDITrack, x);
    Result := output;
  end;

begin
  x := 0;
  TrackNumPointer := pbyte(filetrackpointers[TrackNumber - 1]);
  posMidiTrack := pbyte(TrackNumPointer) + 8;//skip header info
  LengthPointer := (Pointer(TrackNUmPointer)) + 4;
  tLength := BEtoN(LengthPointer^);
  writeln(format('X: %d Header : %p , Length : %d  ', [x, TrackNumPointer, tLength]));
  // test routine for position of header pointer
  repeat
    //get VBL delta time
    delta := vblDecode(posMIDITrack);

    writeln(format('Delta:  %d X: %d    Position : %p     Value : %d  HEX: %x',
      [delta, x, posMidiTrack, posMIDITrack^, posMIDITrack^]) +
      ' ASCII: ' + char(posMIDITrack^));
    //start to breakdown MIDI messages
    //NOT COMPLETE !
    case (posMIDITrack^) of
      $FF:
      begin
        Write('FF ');
        Inc(posMidiTrack);
        //get type  Type will be an enum later
        eventType := posMidiTrack^;
        Inc(posMIDITrack);
        //get length
        eventLength := (posMIDITrack^);
        Inc(PosMIDITrack, eventLength + 1);
        writeln(format('Event Type : %d     Event Length : %d     ',
          [eventType, eventLength]));
      end;
    end;
    case (posMIDITrack^ and $F0) of
      $80:
      begin
        Write('  Channel : ');
        Write(posMIDItrack^ and $0F); //get channel = posMIDITrack^ and $0F??
        Inc(posMIDItrack);
        Write('  Note off ');
        Write(posMIDITrack^); //get note
        Inc(posMIDITrack);
        Write('  Velocity : ');
        Writeln(posMIDITrack^); //get velocity
        //writeln((posMIDITrack^ and $0F) + 1);
        Inc(posMIDITrack);
      end;
      $90:
      begin
        Write('  Channel : ');
        Write(posMIDItrack^ and $0F); //get channel = posMIDITrack^ and $0F??
        Inc(posMIDItrack);
        Write('  Note off ');
        Write(posMIDITrack^); //get note
        Inc(posMIDITrack);
        Write('  Velocity : ');
        Writeln(posMIDITrack^); //get velocity
        //writeln((posMIDITrack^ and $0F) + 1);
        Inc(posMIDITrack);
      end;
      //needs other meta-events here (aftertouch, pitchbend, etc.)
    end;
    Inc(x);
  until x = tLength;
  Result := '';
end;

function TMIDIer.vblDecode(bytePoint: Pointer): longword; inline;
var
  w: ^byte;
  x: byte;
  output: longword;
begin
  // $81 and $7F should be 255
  // $82 , $80, and $00 = 32768
  x := 0;
  output := 0;
  repeat
    w := bytePoint + x;
    Inc(x);
    output := ((output shl 7) or ((w^ and $7F)));
  until (byte(w^) and $80) = 0;
  Result := output;
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
