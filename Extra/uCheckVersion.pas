unit uCheckVersion;

interface

uses
  System.Classes, IdHTTP, System.SysUtils, Winapi.Windows, Winapi.Messages,
  System.Generics.Collections, udmMain, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type
  TCheckVersion = class(TThread)
  private
    FVersion: String;
    FLicence: String;
    FHandle: THandle;
    FRoutineVer: String;
    FRoutineBit: Integer;
    FDBVer: Integer;
    FHttp: TIdHTTP;
    FSSL: TIdSSLIOHandlerSocketOpenSSL;
  protected
    procedure Execute; override;
  public
    class procedure CreateAndRun(AHandle: THandle; AVersion: String; ALicence: String; ARoutineVer: String; ARoutineBit: Integer; ADBVer: Integer);
  end;

  PAvaibleVersion = packed record
    ApplicationUrl: string;
    ApplicationVer: string;
    SetupUrl: string;
    RoutineUrl: string;
    RoutineVer: string;
    PatchUrl: string;
    PatchVer: string;
    PatchFile: string;
    //
    FileCount: Integer;
    Files: array of string;
  end;
  RAvaibleVersion = ^PAvaibleVersion;

const
  C_URL = 'wp-content/uploads/files/checkupdatepatch.php'; //checkupdate.php
  //
  WM_NEW_VERSION = WM_USER + 100;

implementation

uses
  System.NetEncoding, System.JSON, Soap.EncdDecd, IdMultipartFormData;


{ TCheckVersion }

class procedure TCheckVersion.CreateAndRun(AHandle: THandle; AVersion,
  ALicence: String; ARoutineVer: String; ARoutineBit: Integer; ADBVer: Integer);
var
  oTh: TCheckVersion;
begin
  oTh := Self.Create(True);
  oTh.FreeOnTerminate := True;
  oTh.FHandle := AHandle;
  oTh.FVersion := AVersion;
  oTh.FLicence := ALicence;
  oTh.FRoutineVer := ARoutineVer;
  oTh.FRoutineBit := ARoutineBit;
  oTh.FDBVer := ADBVer;
  oTh.Start();
end;

procedure TCheckVersion.Execute;
var
  oSS: TStringStream;
  sData: String;
  oJSON: TJSONObject;
  bAvailable: Boolean;
  sUrl: String;
  iMajor,
  iMinor,
  iRelease: Integer;
  sVer: TArray<string>;
  oIn: TStringList;
  oSend: RAvaibleVersion;
  oJSONFiles: TJSONArray;
  ii: Integer;
begin
  inherited;
  try
    FHttp := TIdHTTP.Create(nil);
    try
      bAvailable := False;
      sUrl := '';
      iMajor := -1;
      iMinor := -1;
      iRelease := -1;

      //FHttp.HandleRedirects := True;

      FSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      FHttp.Request.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36';
      FHttp.IOHandler := FSSL;
      FSSL.SSLOptions.Method := sslvSSLv23;
      FSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_1, sslvTLSv1];

      sVer := FVersion.Split(['.']);
      if (Length(sVer) > 0) then begin
        iMajor := StrToIntDef(sVer[0], -1);
        if (Length(sVer) > 1) then begin
          iMinor := StrToIntDef(sVer[1], -1);
          if (Length(sVer) > 2) then
            iRelease := StrToIntDef(sVer[2], -1);
        end;
      end;

      oSS := TStringStream.Create();
      oIn := TStringList.Create();

      oJSON := TJSONObject.Create;
      try
        oJSON.AddPair('major', TJSONNumber.Create(iMajor));
        oJSON.AddPair('minor', TJSONNumber.Create(iMinor));
        oJSON.AddPair('release', TJSONNumber.Create(iRelease));
        oJSON.AddPair('licence', FLicence);
        oJSON.AddPair('routinever', FRoutineVer);
        oJSON.AddPair('routinebit', TJSONNumber.Create(FRoutineBit));
        oJSON.AddPair('dbver', TJSONNumber.Create(FDBVer));
        sData := oJSON.ToString();
      finally
        FreeAndNil(oJSON);
      end;
      //
      sData := '?data=' + EncodeString(sData);
      sData := StringReplace(sData, #$0D+#$0A, '', [rfReplaceAll]);
      FHttp.Get('https://gsc.biz.pl/wp-content/uploads/files/checkupdate.php' + sData, oSS);
      if (oSS.DataString = '') then
        Exit;

      oJSON := TJSONObject.ParseJSONValue(oSS.DataString) as TJSONObject;
      try
        if (not Assigned(oJSON)) then
          Exit;

        if (Assigned(oJSON.Get('available'))) and (oJSON.Get('available').JsonValue is TJSONNumber) then
          bAvailable := TJSONNumber(oJSON.Get('available').JsonValue).AsInt = 1;

        if (bAvailable) then begin
          //FillChar(oURL, High(oUrl), #0);
          //StrPLCopy(@oURL, sUrl, High(oURL));
          New(oSend);
          oSend.FileCount := 0;
          SetLength(oSend.Files, 0);
          if (Assigned(oJSON.Get('setupurl'))) and (oJSON.Get('setupurl').JsonValue is TJSONString) then
            oSend.SetupUrl := TJSONString(oJSON.Get('setupurl').JsonValue).Value.Trim;
          if (Assigned(oJSON.Get('applicationurl'))) and (oJSON.Get('applicationurl').JsonValue is TJSONString) then
            oSend.ApplicationUrl := TJSONString(oJSON.Get('applicationurl').JsonValue).Value.Trim;
          if (Assigned(oJSON.Get('applicationver'))) and (oJSON.Get('applicationver').JsonValue is TJSONString) then
            oSend.ApplicationVer := TJSONString(oJSON.Get('applicationver').JsonValue).Value.Trim;
          if (Assigned(oJSON.Get('routineurl'))) and (oJSON.Get('routineurl').JsonValue is TJSONString) then
            oSend.RoutineUrl := TJSONString(oJSON.Get('routineurl').JsonValue).Value.Trim;
          if (Assigned(oJSON.Get('routinever'))) and (oJSON.Get('routinever').JsonValue is TJSONString) then
            oSend.RoutineVer := TJSONString(oJSON.Get('routinever').JsonValue).Value.Trim;

          if (Assigned(oJSON.Get('patchurl'))) and (oJSON.Get('patchurl').JsonValue is TJSONString) then
            oSend.PatchUrl := TJSONString(oJSON.Get('patchurl').JsonValue).Value.Trim;
          if (Assigned(oJSON.Get('patchver'))) and (oJSON.Get('patchver').JsonValue is TJSONString) then
            oSend.PatchVer := TJSONString(oJSON.Get('patchver').JsonValue).Value.Trim;
          if (Assigned(oJSON.Get('patchfile'))) and (oJSON.Get('patchfile').JsonValue is TJSONString) then
            oSend.PatchFile := TJSONString(oJSON.Get('patchfile').JsonValue).Value.Trim;

          if (Assigned(oJSON.Get('files'))) and (oJSON.Get('files').JsonValue is TJSONArray) then begin
            oJSONFiles := oJSON.Get('files').JsonValue as TJSONArray;
            oSend.FileCount := oJSONFiles.Count;
            SetLength(oSend.Files, oJSONFiles.Count);
            for ii := 0 to oJSONFiles.Count - 1 do
              oSend.Files[ii] := oJSONFiles.Items[ii].Value;
          end;

          SendMessage(FHandle, WM_NEW_VERSION, 1, Integer(oSend));
        end;

      finally
        FreeAndNil(oJSON);
      end;


    finally
      FreeAndNil(FSSL);
      FreeAndNil(FHttp);
      FreeAndNil(oSS);
      FreeAndNil(oIn);
    end;
  except

  end;
end;

end.

