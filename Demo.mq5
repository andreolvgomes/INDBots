//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

double lotSize = 0.1;    // Tamanho do lote
double stopLoss = 100;   // Stop Loss em pontos
double takeProfit = 200; // Take Profit em pontos
double offset = 10;      // Distância do Sell Limit em pontos

int horaInicio = 10;

//-- OnInit
int OnInit()
  {
   ChartSetInteger(0, CHART_SHOW_GRID, false); // false to remove grid
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);

   return(INIT_SUCCEEDED);
  }
bool japosicionado = false;
//-- OnTick
void OnTick()
  {
   MqlDateTime tempoAtual;
   TimeCurrent(tempoAtual);

// Executa somente após as 10:00  

   if(japosicionado)
      return;

// Obtém o preço atual do Ask
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

// Calcula o preço do Sell Limit
   double sellLimitPrice = NormalizeDouble(price + offset * _Point, _Digits);

// Calcula SL e TP
   double sl = NormalizeDouble(sellLimitPrice + stopLoss * _Point, _Digits);
   double tp = NormalizeDouble(sellLimitPrice - takeProfit * _Point, _Digits);

// Envia a ordem pendente
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);

   request.action = TRADE_ACTION_PENDING;
   request.type = ORDER_TYPE_SELL_LIMIT;
   request.symbol = _Symbol;
   request.volume = lotSize;
   request.price = sellLimitPrice;
   request.sl = sl;
   request.tp = tp;
   request.expiration = 100;
   request.deviation = 10;
   request.magic = 123456;
   request.comment = "Sell Limit EA";
   request.type_filling = ORDER_FILLING_FOK;
   request.type_time = ORDER_TIME_GTC;

   if(!OrderSend(request, result))
     {
      Print("Erro ao enviar ordem: ", result.retcode);
     }
   else
     {
      Print("Ordem Sell Limit enviada em ", sellLimitPrice);
     }
     
     japosicionado = true;
  }

//+------------------------------------------------------------------+
