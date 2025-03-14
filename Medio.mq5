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

#include <TradeManager\Signal\SignalMedio.mqh>
#include <TradeManager\Trailing\TrailingNone.mqh>

input ENUM_TIMEFRAMES    TimerFrame =1;//TimeFrame
input string StartAt ="09:00";//Hora de Início

ManagerExpert *manager;

//-- OnInit
int OnInit()
  {
   ChartSetInteger(0, CHART_SHOW_GRID, false); // false to remove grid
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);

   manager = new ManagerExpert;
   manager.Init(TimerFrame, 123456);
   manager.SetInputPartial1(1,500);
   manager.SetInputPartial2(1,1000);
   manager.SetInputPartial3(1,1500);
   manager.SetExpiration(1);

   manager.SetHoursLimits("10:00", "17:00", "17:30");

   SignalMedio *signal = new SignalMedio;
   signal.SetIsReserve(false);
   manager.InitSignal(signal);

   TrailingNone *trailing = new TrailingNone;
   manager.InitTrailing(trailing);

   ManagerRisk *risk = new ManagerRisk;
   risk.SetLots(1);
   risk.SetMaximumInputs(1);
//risk.SetMaximumLoss(1000);
//risk.SetMaximumProfit(100);
   manager.InitRisk(risk);

   return(INIT_SUCCEEDED);
  }
//-- OnTick
void OnTick()
  {
   manager.Execute();
  }
//+------------------------------------------------------------------+
