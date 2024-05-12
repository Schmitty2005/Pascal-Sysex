{$mode Delphi}

unit midiTrack;

interface

uses
  Classes, SysUtils;

type

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

function TMidiTrackEvent.get_param1: byte ;
begin
  Result := BEToN(param1); // needs work to break down properly!
end;

function TMidiTrackEvent.get_param2: byte;
begin
  Result := BEToN(param2); // needs work to break down properly!
end;

end.
