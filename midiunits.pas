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
      procedure setLsb ( newLsb : Byte) ;
      procedure setMsb ( newMsb : Byte) ;
    public
      property msb : byte  read p_msb write setLsb;
      property lsb : byte read p_lsb write setLsb;
      property value : word read p_value write setBytes;
  end;


implementation
procedure  Tmsblsb.setBytes ( toConvert : Word );
Begin
  ;;;
end;

procedure Tmsblsb.setLsb ( newLsb : Byte) ;
  Begin
     ;;;
  end;

procedure Tmsblsb.setMsb ( newMsb : Byte) ;
  Begin
    ;;;
  end;

end.

