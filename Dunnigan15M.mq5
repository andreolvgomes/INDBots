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

input ENUM_TIMEFRAMES    TimerFrame =15;//TimeFrame
input int    Lots =1;//Lots
input int    Num_barras  =3;//Números de Barras
input int    TakeProfit  =300;//Take Profit
input int    StopLoss  =100;//Stop Loss
input string StartAt ="10:00";//Hora de Início
input string EndAt ="14:00";//Fim de Entradas

ManagerExpert *manager;

//-- OnInit
int OnInit()
  {
   ChartSetInteger(0, CHART_SHOW_GRID, false); // false to remove grid
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);

   manager = new ManagerExpert;
   manager.Init(TimerFrame, 123456);
   manager.SetExpiration(1);

   manager.SetHoursLimits(StartAt, EndAt, "16:00");

   SignalDunnigan *signal = new SignalDunnigan;
   signal.SetNumberBars(Num_barras);
   signal.Init30m();
   signal.SetStopLoss(StopLoss);
   signal.SetTakeProfit(TakeProfit);
   manager.InitSignal(signal);

   TrailingNone *trailing = new TrailingNone;
   manager.InitTrailing(trailing);

   ManagerRisk *risk = new ManagerRisk;
   risk.SetLots(Lots);
//risk.SetMaximumInputs(10);
//risk.SetMaximumLoss(10000);
//risk.SetMaximumProfit(10000);
   manager.InitRisk(risk);

   return(INIT_SUCCEEDED);
  }
//-- OnTick
void OnTick()
  {
   manager.Execute();
  }
//+------------------------------------------------------------------+
