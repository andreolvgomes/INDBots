//+------------------------------------------------------------------+
//|                                                     Dunnigan.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Arrays/ArrayObj.mqh>
#include <Arrays/ArrayString.mqh>

#include <TradeManager\ManagerExpert.mqh>
#include <TradeManager\ManagerTrailing.mqh>
#include <TradeManager\ManagerSignal.mqh>
#include <TradeManager\ManagerRisk.mqh>

#include <TradeManager\Signal\SignalDunnigan.mqh>
#include <TradeManager\Signal\Dunnigan\ParamsConfig.mqh>
#include <TradeManager\Trailing\TrailingNone.mqh>

#import "shell32.dll"
int ShellExecuteW(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import

input group "Parâmetros do Setup"
input ENUM_TIMEFRAMES        TimerFrame =15;          //TimeFrame
input     int                Num_barras  =3;          //Números de Barras
input     int                AmplitudeMovimento=400;       //Amplitude do movimento Mínimas/Máximas
input     int                AmplitudeAlvo = 400;   //Movimentos com alvos
input     int                LevelStopLoss=20;        //Level Stop Loss
//input     bool               EntryWithConfirmation=false;//Dunning Original;Entrar após gatilho com stop atrás do candle

input group "Gerenciamento de Risco"
input     int                Lots =1;//Lot
input     int                TakeProfit  =500;        //Take Profit
input     int                StopLoss  =100;          //Stop Loss
input     int                NumEntradasPorDia = 0;   //Qt. Trades por dia

input group "Outros"
input     ENUM_TIMEFRAMES    TimerFrameMaior =30;     //TimeFrame Maior
input     int                Num_barrasMaior  =0;     //Números de Barras Maior
input     bool                EnviarMessage=false;     //Enviar mensagem Telegram

input group "Confirmação em outros TimeFrame"
input     bool               Analisar1=false;         //Analisar1
input     ENUM_TIMEFRAMES    TimerDunnigan1=5;        //TimerDunnigan1
input     bool               Analisar2=false;         //Analisar2
input     ENUM_TIMEFRAMES    TimerDunnigan2 =1;       //TimerDunnigan2

input group "Limites/Horários"
input     string             StartAt ="10:00";//Hora de Início
input     string             EndAt ="14:00";//Fim de Entradas

static datetime candle_mensagem_enviada=0;
int devQtSend = 0;

ManagerExpert *manager;
SignalDunnigan *signal;

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
   manager.Init(TimerFrame, 123456);
   manager.SetExpiration(1);
   manager.SetLookingSignalAllDay(true);
   manager.SetHoursLimits(StartAt, EndAt, "17:00");
//manager.AddPartialEntry(1, 200);
//manager.AddPartialEntry(1, 300);

   ParamsConfig params;
   params.SetNumber_barras(Num_barras);
   params.SetStopLoss(StopLoss);
   params.SetTakeProfit(TakeProfit);
   params.SetPeriod(TimerFrame);
   params.SetLevel_stoploss(LevelStopLoss);
   params.SetAmplitudeAlvos(AmplitudeAlvo);
   params.SetNumber_barras_maior(Num_barrasMaior);
   params.SetAmplitude_movimento(AmplitudeMovimento);
   params.SetAnalisar1(Analisar1);
   params.SetAnalisar2(Analisar2);
   params.SetPeriod1(TimerDunnigan1);
   params.SetPeriod2(TimerDunnigan2);
   params.SetPerdiodMaior(TimerFrameMaior);

   signal = new SignalDunnigan;
   signal.SetMinutesLastOperation(15);//só abre uma nova operação 15m depois da última
   signal.SetParams(&params);
//signal.m_entry_all = true;

   signal.SetIsReserve(false);
   signal.SetStopLoss(StopLoss);
   signal.SetTakeProfit(TakeProfit);
   manager.InitSignal(signal);

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
//-- OnTick
void OnTick()
  {
   manager.Execute();
   SendMessage();
  }
//+------------------------------------------------------------------+
void SendMessage()
  {  
   if(signal.isBuy || signal.isSell)
     {
      bool breakpoint = false;
      if(EnviarMessage)
        {
         datetime lastbar_timed=SeriesInfoInteger(Symbol(),TimerFrame,SERIES_LASTBAR_DATE);
         if(candle_mensagem_enviada ==0 || candle_mensagem_enviada!=lastbar_timed)
           {
            // limita as mensagens no ambiente de dev
            if(MQLInfoInteger(MQL_TESTER) && devQtSend>0)
               return;

            candle_mensagem_enviada=lastbar_timed;

            string message = "";
            if(signal.isBuy)
              {
               message ="Buy";
               message +="\nCandle: "+ signal.TimeCurrentBar();
              }
            if(signal.isSell)
              {
               message ="Sell";
               message +="\nCandle: "+ signal.TimeCurrentBar();
              }

            if(MQLInfoInteger(MQL_TESTER))
               message = ">>Test<<\n"+message;

            // pra regular as mensagens no ambiente de dev
            devQtSend++;

            double price, sl, tp=0;
            signal.GetValues(price, sl, tp);
            message += "\nPrice: " + DoubleToString(price, 2);
            message += "\nSl: " + DoubleToString(sl, 2);
            message += "\nTp: " + DoubleToString(tp, 2);

            CArrayString mensagens;
            if(signal.isBuy)
               signal.MessagesConfirmationsBuy(&mensagens);
            if(signal.isSell)
               signal.MessagesConfirmationsSell(&mensagens);

            if(mensagens.Total() > 0)
              {
               message+="\n\nRegras:";
               for(int i=0;i<mensagens.Total();i++)
                  message += "\n→ "+ mensagens.At(i);
              }
            else
              {
               message+="\n\nRegras: Atendidas!!!";
              }

            message ="\"" + message+"\"";

            string botsend = "C:\\botsend\\botsend.exe";
            int resultado = ShellExecuteW(0, "open", botsend, message, "", 0);
           }
        }
     }
  }
//+------------------------------------------------------------------+
