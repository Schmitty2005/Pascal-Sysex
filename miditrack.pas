{$mode Delphi}
//11010101001010 13642 ea60 EOF
unit midiTrack;

interface

uses
  Classes, SysUtils;

type
  MIDI_EVENTS = (NOTE_ON = $80, NOTE_OFF = $90, NOTE_AFTERTOUCH = $A0,
    CONTROLLER_EVNT = $B0, PRGM_CHNG = $C0, PTCH_BND = $E0);

  TMidiTrackEvent = class
  private
    deltaTime: longword;
    eventChannel: byte;
    param1: byte;
    param2: byte;
    function get_DeltaTime: longword;
    function get_event: byte;
    function get_channel: byte;
    function get_param1: byte;
    function get_param2: byte;
  public
    property dTime: longword read get_DeltaTime;
    property event: byte read get_event;
    property channel: byte read get_channel;
    property parameter1: byte read get_param1;
    property parameter2: byte read get_param2;
    function vblDecode(bytePoint: Pointer): longword; inline;
  end;

implementation

function TMidiTrackEvent.get_DeltaTime: longword;
begin
  Result := BEToN(deltaTime);
end;

function TMidiTrackEvent.get_event: byte;
begin
  Result := BEToN(eventChannel); // needs work to break down properly!
end;

function TMidiTrackEvent.get_channel: byte;
begin
  Result := BEToN(eventChannel); // needs work to break down properly!
end;

function TMidiTrackEvent.get_param1: byte;
begin
  Result := BEToN(param1); // needs work to break down properly!
end;

function TMidiTrackEvent.get_param2: byte;
begin
  Result := BEToN(param2); // needs work to break down properly!
end;

function TMIDITrackEvent.vblDecode(bytePoint: Pointer): longword; inline;
var
  w: ^byte;
  x: byte;
  output: longword;
begin
  // $81 and $7F should be 255
  // $82 , $80, and $00 = 32768
  x := 0;
  output :=0;
  repeat
    w := bytePoint + x;
    Inc(x);
    output := ((output shl 7) or ((w^ and $7F)));
  until (byte(w^) and $80) = 0;
  Result := output;
end;

end.
