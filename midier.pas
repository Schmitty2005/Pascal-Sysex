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
  note: byte;
  velocity: byte;
  tLength: word;
  TrackNumPointer: pbyte;
  LengthPointer: PDword;
  x: Qword;
  runningStatus: byte;
  delta: longword;
  eventLength: longword;
  eventText: shortstring;

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
    Inc(posMIDITrack, x);
    Result := output;
  end;

begin
  x := 0;
  TrackNumPointer := pbyte(filetrackpointers[TrackNumber - 1]);
  posMidiTrack := pbyte(TrackNumPointer) + 8;//skip header info
  LengthPointer := (Pointer(TrackNUmPointer)) + 4;
  tLength := BEtoN(LengthPointer^);
  runningStatus := 0;
  writeln(format('X: %d Header : %p , Length : %d  ', [x, TrackNumPointer, tLength]));
  delta := vblDecode(posMIDITrack); //get initial delta time

  repeat

    if (posMIDITrack^) > $7F then
    begin
      runningStatus := posMIDITrack^;
      Inc(posMIDItrack);
    end;

    case (runningStatus) of
      $FF:
      begin
        //Inc(posMIDITrack);
        runningStatus := 0; // Running status cannot work on $FF
        case (posMIDITrack^) of
          $03://name of seq or track
          begin
            Inc(posMIDITrack);
            eventLength := (posMIDItrack^);
            eventText := (pshortstring(posMIDItrack)^);
            Write('Track Name: ' + ansistring(eventText) + sLineBreak);
            Inc(posMIDITrack, eventLength + 1);
          end;
          $51: Inc(posMIDITrack, 5);//DEC 81 tempo
          $58: Inc(posMIDITrack, 6);//DEC 88
          $81: Inc(posMIDItrack, 3);//DEC
          $2F:
          begin
            writeln('END OF TRACK!');
            x := tLength; //not the best way to handle EOF;
          end;
        end;//End $FF parse case
      end;

      $80..$8F:
      begin
        note := posMIDITrack^;
        Inc(posMIDITrack);
        velocity := posMIDITrack^;
        Inc(PosMIDITrack);
        writeln(format ('Note OFF : %d  Vel : %d  delta : %d', [note, velocity, delta]));

      end;

      $90..$9F:
      begin
        note := posMIDITrack^;
        Inc(posMIDITrack);
        velocity := posMIDITrack^;
        Inc(PosMIDITrack);
        writeln(format ('Note ON  : %d  Vel : %d  delta : %d', [note, velocity, delta]));
      end;

      $A0..$AF:
        Inc(posMIDItrack, 3);//aftertouch 2 byte

      $B0..$BF:
        Inc(posMIDItrack, 3);//control  2 byte

      $C0..$CF:
        Inc(posMIDItrack, 2);//program change  1 byte

      $D0..$DF:
        Inc(posMIDItrack, 3);//channel pressure  2 bytes

      $E0..$EF:
        Inc(posMIDItrack, 3);//pitch bend  2 bytes
    end; //End event Code case


// Page 136 of MIDI Spec for Files :
   // All meta-events begin with FF, then have an event type byte
   //(which is always less than 128), and then have the length of the data
   //stored as a variable-length quantity, and then the data itself.
   //If there is no data, the length is 0.

    //There is always a delta time after and event.  There may or may not be a
    //status byte!  Delta times can start with $80!  So, after an event
    // $90 $NOTE $VEL, there will be a delta time, possibly followed by another
    //event code, if not, then previous event code applies to next $NOTE $VEL

    delta := vblDecode(posMIDITrack);
  until x = tLength; // update to use posMIDItrack pointer - start = tlength
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
{
Channel Note Messages
$    BYTES   Dta Lngth  Function
8nH 1000nnnn 2        Note Off
9nH 1001nnnn 2        Note On (a velocity of 0 = Note Off)
AnH 1010nnnn 2        Polyphonic key pressure/Aftertouch
BnH 1011nnnn 2        Control change
CnH 1100nnnn 1        Program change
DnH 1101nnnn 1        Channel pressure/After touch
EnH 1110nnnn 2        Pitch bend chang
}
