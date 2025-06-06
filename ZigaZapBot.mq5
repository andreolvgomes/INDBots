//+------------------------------------------------------------------+
//|                                                    PureZZEA.mq5 |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Utility\ZigZagModule.mqh>
#include <Trade\Trade.mqh>

//--- Parâmetros de entrada
input int      InpMinImpulseSize = 200;    // Tamanho mínimo do movimento (pontos)
input int      InpMaxExtremums = 5;        // Número de extremos a rastrear
input double   InpLotSize = 1;           // Tamanho do lote
input int      InpStopLoss = 200;          // Stop Loss (pontos)
input int      InpTakeProfit = 400;        // Take Profit (pontos)
input bool     InpShowSegments = true;     // Mostrar segmentos no gráfico
input color    InpSegmentColor = clrRed;  // Cor dos segmentos

//--- Variáveis globais
CZigZagModule  zz;
CTrade         trade;
MqlRates       rates[];
bool           first_run = true;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);

//--- Configura a classe ZigZagModule
   zz.CopyExtremums(InpMaxExtremums);
   zz.LinesColor(InpSegmentColor);

//--- Configura a classe de negociação
   trade.SetExpertMagicNumber(12345);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(Symbol());

//--- Carrega os dados históricos
   ArraySetAsSeries(rates, true);
   CopyRates(Symbol(), Period(), 0, InpMaxExtremums*10, rates);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   zz.DeleteSegments();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { 
    zz.LinesColor(InpSegmentColor);
//--- Atualiza os dados de preço
   if(CopyRates(Symbol(), Period(), 0, InpMaxExtremums*10, rates) <= 0)
      return;

//--- Processa os dados para o ZigZag
   ProcessZZData();

//--- Verifica padrões se tivermos dados suficientes
   if(zz.CopyExtremums() >= 3)
      CheckTradingPatterns();

//--- Mostra os segmentos se habilitado
   if(InpShowSegments)
      zz.ShowSegments();
  }
//+------------------------------------------------------------------+
//| Processa os dados para o ZigZag                                  |
//+------------------------------------------------------------------+
void ProcessZZData()
  {
   double highs[], lows[];
   datetime times[];

   ArrayResize(highs, ArraySize(rates));
   ArrayResize(lows, ArraySize(rates));
   ArrayResize(times, ArraySize(rates));

   for(int i=0; i<ArraySize(rates); i++)
     {
      highs[i] = rates[i].high;
      lows[i]  = rates[i].low;
      times[i] = rates[i].time;
     }

//--- Aplica filtro de tamanho mínimo (MinImpulseSize)
   for(int i=1; i<ArraySize(highs); i++)
     {
      if(MathAbs(highs[i]-lows[i-1]) < InpMinImpulseSize*_Point)
         highs[i] = 0;
      if(MathAbs(lows[i]-highs[i-1]) < InpMinImpulseSize*_Point)
         lows[i] = 0;
     }

//--- Atualiza o ZigZagModule
   zz.GetZigZagData(highs, lows, times);
  }
//+------------------------------------------------------------------+
//| Verifica padrões de negociação                                   |
//+------------------------------------------------------------------+
void CheckTradingPatterns()
  {
//--- 1. Padrão de Reversão (Topo/Fundo mais alto/baixo)
   if(zz.Direction() > 0 && zz.HighPrice(0) > zz.HighPrice(1) && zz.LowPrice(1) > zz.LowPrice(2))
     {
      double entry = rates[0].close;
      double sl    = zz.LowPrice(1) - InpStopLoss*_Point;
      double tp    = entry + (entry-sl)*2;
      trade.Buy(InpLotSize, NULL, entry, sl, tp, "Reversão Compra");
     }
   else
      if(zz.Direction() < 0 && zz.LowPrice(0) < zz.LowPrice(1) && zz.HighPrice(1) < zz.HighPrice(2))
        {
         double entry = rates[0].close;
         double sl    = zz.HighPrice(1) + InpStopLoss*_Point;
         double tp    = entry - (sl-entry)*2;
         trade.Sell(InpLotSize, NULL, entry, sl, tp, "Reversão Venda");
        }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
