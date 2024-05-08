{$mode Delphi}
unit midiUnits;

interface

uses
  Classes, SysUtils;

type
    Pbyte = Pointer;//^byte;
    Pvalue = Pointer;//^word;

  Tmsblsb = class
  private
    p_msb: byte;
    p_lsb: byte;
    p_value: word;
    PointValue: Pvalue;
    Pointmsb : Pbyte;
    Pointlsb : Pbyte;

    procedure setBytes(toConvert: word);
    procedure setLsb(newLsb: byte);
    procedure setMsb(newMsb: byte);
  public
    property msb: byte read p_msb write setLsb;
    property lsb: byte read p_lsb write setLsb;
    property Value: word read p_value write setBytes;
  end;


implementation

procedure Tmsblsb.setBytes(toConvert: word);
begin
  ;
  //TEMP
  p_value := toConvert;

  //Pointmsb  := @p_value;
  //Pointlsb := inc(Pointmsb);

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
