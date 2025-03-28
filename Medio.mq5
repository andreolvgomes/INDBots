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

   manager.AddPartialEntry(1, 500);
   manager.AddPartialEntry(1, 1000);
   manager.AddPartialEntry(1, 1500);
   manager.AddPartialEntry(1, 2000);

   manager.AddBreakEven(200, 10);
   manager.AddBreakEven(300, 50);
   manager.AddBreakEven(500, 100);
   manager.AddBreakEven(600, 150);

   manager.AddPartialOut(1, 100);
   manager.AddPartialOut(1, 200);
   manager.AddPartialOut(1, 300);
   manager.AddPartialOut(1, 400);

   manager.SetExpiration(1);

   manager.SetHoursLimits("13:00", "17:00", "17:30");

   SignalMedio *signal = new SignalMedio;
   signal.SetIsReserve(false);
   signal.SetStopLoss(2500);
   manager.InitSignal(signal);

   TrailingNone *trailing = new TrailingNone;
   manager.InitTrailing(trailing);

   ManagerRisk *risk = new ManagerRisk;
   risk.SetLots(10);
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
