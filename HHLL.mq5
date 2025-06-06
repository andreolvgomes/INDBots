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

#include <TradeManager\Signal\SignalHHLL.mqh>
#include <TradeManager\Trailing\TrailingNone.mqh>

ManagerExpert *manager;
SignalHHLL *signal;

//-- OnInit
int OnInit()
  {
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);

   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, 65280);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, 10061943);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, 10061943);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, 255);

   manager = new ManagerExpert;
   manager.Init(PERIOD_CURRENT, 123456);
   manager.SetExpiration(1);
   manager.SetHoursLimits("10:00", "17:00", "17:00");
   
   signal = new SignalHHLL;
   signal.SetIsReserve(false);
   signal.SetStopLoss(100);
   signal.SetTakeProfit(500);
   manager.InitSignal(signal);

   TrailingNone *trailing = new TrailingNone;
   manager.InitTrailing(trailing);

   ManagerRisk *risk = new ManagerRisk;
   risk.SetLots(1);
   manager.InitRisk(risk);

   return(INIT_SUCCEEDED);
  }

//-- OnTick
void OnTick()
  {
   manager.Execute();
  }
//+------------------------------------------------------------------+
