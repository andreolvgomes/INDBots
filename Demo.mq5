//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#import "shell32.dll"
int ShellExecuteW(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import

//-- OnInit
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//-- OnTick
void OnTick()
  {
   string caminhoExe = "C:\\send\\send.exe"; // Altere para o caminho correto
   int resultado = ShellExecuteW(0, "open", caminhoExe, "teste", "", 0);
  }
