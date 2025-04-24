//+------------------------------------------------------------------+
//|                                                  12Invertido.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerExpert.mqh>
#include <TradeManager\ManagerTrailing.mqh>
#include <TradeManager\ManagerSignal.mqh>
#include <TradeManager\ManagerRisk.mqh>

#include <TradeManager\Signal\OneTwoInvertido.mqh>
#include <TradeManager\Trailing\TrailingNone.mqh>

ManagerExpert *manager;

//+------------------------------------------------------------------+
int OnInit()
  {
   ChartSetInteger(0, CHART_SHOW_GRID, false); // false to remove grid
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);

   manager = new ManagerExpert;
   manager.Init(PERIOD_CURRENT, 123456);
   manager.SetExpiration(1);

   OneTwoInvertido *signal = new OneTwoInvertido;
   signal.SetIsReserve(false);
   signal.SetStopLoss(100);
   signal.SetTakeProfit(300);
   manager.InitSignal(signal);

   TrailingNone *trailing = new TrailingNone;
   manager.InitTrailing(trailing);

   ManagerRisk *risk = new ManagerRisk;
   risk.SetLots(1);
   manager.InitRisk(risk);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   manager.Execute();
  }
//+------------------------------------------------------------------+
