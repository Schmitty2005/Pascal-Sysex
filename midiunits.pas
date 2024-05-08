{$mode Delphi}
unit midiUnits;

interface

uses
  Classes, SysUtils;

Type
Tmsblsb = class
    private
      p_msb : Byte;
      p_lsb : Byte;
      p_value : Word;
      procedure  setBytes ( toConvert : Word );
    public
      property msb : byte  read p_msb;
      property lsb : byte read p_lsb;
      property value : word read p_value write setBytes;
  end;


implementation
procedure  Tmsblsb.setBytes ( toConvert : Word );
Begin
  ;;;
end;

end.

