//+------------------------------------------------------------------+
//|                                                     Dunnigan.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerExpert.mqh>
#include <TradeManager\ManagerTrailing.mqh>
#include <TradeManager\ManagerSignal.mqh>
#include <TradeManager\ManagerRisk.mqh>

#include <TradeManager\Signal\SignalDunnigan.mqh>
#include <TradeManager\Trailing\TrailingNone.mqh>

// --- Parâmetros de Negociação ---
input ENUM_TIMEFRAMES    TimerFrame =15;//TimeFrame
input int    Lots =1;//Lots
input int    Num_barras  =3;//Números de Barras
input int    TakeProfit  =500;//Take Profit
input int    StopLoss  =100;//Stop Loss
input int    AmplitudeAlvo=400;//Calcular amplitude para alvo
input bool    EntryWithConfirmation=false;//Dunning Original

input string   Delimitador1 = "";    // --------------------------
// --- Timer Maior ---
input ENUM_TIMEFRAMES    TimerFrameMaior =30;//TimeFrame Maior
input int    Num_barrasMaior  =0;//Números de Barras Maior

input string   delimitadorOutroTimerFrame = "";    // ------------Mais Confirmações Dunnigan--------------
input bool    Analisar1=false;//Analisar1
input ENUM_TIMEFRAMES    TimerDunnigan1=5;//TimerDunnigan1
input bool    Analisar2=false;//Analisar2
input ENUM_TIMEFRAMES    TimerDunnigan2 =1;//TimerDunnigan2

// --- Parâmetros Avançados ---
input string StartAt ="10:00";//Hora de Início
input string EndAt ="14:00";//Fim de Entradas
input int NumEntradasPorDia = 0;

ManagerExpert *manager;
SignalDunnigan *signal;

//-- OnInit
int OnInit()
  {
   ChartSetInteger(0, CHART_SHOW_GRID, false); // false to remove grid
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);

   manager = new ManagerExpert;
   manager.Init(TimerFrame, 123456);
   manager.SetExpiration(1);
   if(EntryWithConfirmation)
      manager.SetExpiration(1);
   manager.SetHoursLimits(StartAt, EndAt, "17:00");
//manager.AddPartialEntry(1, 200);
//manager.AddPartialEntry(1, 300);

   signal = new SignalDunnigan;
   signal.SetAmplitudeAlvo(AmplitudeAlvo);
   signal.SetEntryConfirmation(EntryWithConfirmation);
   signal.SetIsReserve(false);
   signal.SetNumberBars(Num_barras);
   signal.InitMaior(TimerFrameMaior,Num_barrasMaior);
   signal.SetStopLoss(StopLoss);
   signal.SetTakeProfit(TakeProfit);
   manager.InitSignal(signal);
   signal.AnalisarDunnigan(Analisar1, Analisar2);
   signal.InitDunnigan(TimerDunnigan1, TimerDunnigan2);

   TrailingNone *trailing = new TrailingNone;
   manager.InitTrailing(trailing);

   ManagerRisk *risk = new ManagerRisk;
   risk.SetLots(Lots);

   risk.SetMaximumInputs(NumEntradasPorDia);
//risk.SetMaximumLoss(10000);
//risk.SetMaximumProfit(10000);
   manager.InitRisk(risk);

   return(INIT_SUCCEEDED);
  }

string last_msg = "";
//-- OnTick
void OnTick()
  {
   manager.Execute();
   
   string msg = signal.GetMensagem();
   if(msg != last_msg)
     {
      last_msg = msg;
      printf(msg);
     }
  }
//+------------------------------------------------------------------+
