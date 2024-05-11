{$mode Delphi}
unit midiUnits;

interface

uses
  Classes, SysUtils;

type
  pbyte = Pointer; //^byte;
  Pvalue = Pointer;//^word;



  Tmsblsb = class
  private
    p_msb: byte;
    p_lsb: byte;

    PointValue: Pvalue;
    Pointmsb: pbyte;
    Pointlsb: pbyte;

    procedure setBytes(toConvert: word);
    procedure setLsb(newLsb: byte);
    procedure setMsb(newMsb: byte);
  public
    p_value: word;
    property msb: byte read p_msb write setLsb;
    property lsb: byte read p_lsb write setLsb;
    property Value: word read p_value write setBytes;
  end;


  // Can use BEtoN to convert Big Endian to native PC
  // Can us NtoBE to convert Native to BE.
implementation

procedure Tmsblsb.setBytes(toConvert: word);
var
  temp: byte;
begin
  ;
  //TEMP

  p_value := toConvert;

  Pointmsb := @p_value;
  Pointlsb := (Pointmsb + 1);
  temp := byte(Pointlsb^);
  ;
end;

procedure Tmsblsb.setLsb(newLsb: byte);
begin
  ;
  ;
  ;
end;

procedure Tmsblsb.setMsb(newMsb: byte);
begin
  ;
  ;
  ;
end;

end.
