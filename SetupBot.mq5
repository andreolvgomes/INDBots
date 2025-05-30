//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
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

input group "Setup 1"
input     bool               Setup1=true;             //[1] Ligar Setup
input ENUM_TIMEFRAMES        TimerFrame =15;          //[1] TimeFrame
input     int                Num_barras  =3;          //[1] Números de Barras
input     int                AmplitudeMovimento=400;  //[1] Amplitude do movimento
input     int                AmplitudeAlvo = 400;     //[1] Movimentos com alvos

input group "Setup 2"
input     bool               Setup2=true;             //[2] Ligar Setup
input ENUM_TIMEFRAMES        TimerFrame2 =5;          //[2] TimeFrame
input     int                Num_barras2  =4;         //[2] Números de Barras
input     int                AmplitudeMovimento2=250; //[2] Amplitude do movimento
input     int                AmplitudeAlvo2 = 250;    //[2] Movimentos com alvos

input group "Gerenciamento de Risco"
input     int                Lots =1;//Lot
input     int                StopLoss  =100;          //Stop Loss
input     int                TakeProfit  =500;        //[1] Take Profit
input     int                TakeProfit2  =300;       //[2] Take Profit
input     int                LevelStopLoss=20;        //[1] Level Stop Loss

input group "Operacional: Regras de Entrada"
input     bool               m_AmplitudeDoMovimentoRules=true;      //Amplitude do movimento
input     bool               m_AmplitudeAlvosRules=true;      //Amplitude do alvo
input     bool               m_AmplitudeDoMovimentoMaxBarsRules = false; //Amplitude do movimento: Todos os candles
input     bool               m_AmplitudeAlvosMaxBarsRules = false; //Amplitude do alvo: Todos os candles
input     bool               m_CandleMesmoDiaRules=true;      //Candles do mesmo dia
input     bool               m_CandleGatilhoMaiorQueAlvoRules=true;      //Candle gatilho maior que alvo
input     bool               m_CandleGatilhoRompeuOsDoisLadosRules = false; //Candle gatilho rompeu os dois lados

input group "Limites/Horários"
input     bool               EnviarMessage=true;      //Enviar mensagem Telegram
input     string             StartAt ="10:00";        //Hora de Início
input     string             EndAt ="14:00";          //Hora de Fim

int devQtSend = 0;

ManagerExpert *manager1;
SignalDunnigan *signal1;

ManagerExpert *manager2;
SignalDunnigan *signal2;

TrailingNone *trailing;
ManagerRisk *risk;

//-- OnInit
int OnInit()
  {
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);

   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, 65280);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, 10061943);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, 10061943);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, 255);

   trailing = new TrailingNone;
   risk = new ManagerRisk;
   risk.SetLots(Lots);

   InitSetup1();
   InitSetup2();

   return(INIT_SUCCEEDED);
  }
//-- OnTick
void OnTick()
  {
   if(Setup1)
     {
      manager1.Execute();
      SendMessage(signal1, manager1, "15M");
     }
   if(Setup2)
     {
      manager2.Execute();
      SendMessage(signal2, manager2, "5M");
     }
  }
//+------------------------------------------------------------------+
void InitSetup1()
  {
   manager1 = new ManagerExpert;
   signal1 = new SignalDunnigan;

   manager1.SetExpiration(1);

   ParamsConfig params;
   params.SetNumber_barras(Num_barras);
   params.SetStopLoss(StopLoss);
   params.SetTakeProfit(TakeProfit);
   params.SetPeriod(TimerFrame);
   params.SetAmplitudeAlvos(AmplitudeAlvo);
   params.SetAmplitude_movimento(AmplitudeMovimento);

   InitStup(signal1, manager1, &params);
  }
//+------------------------------------------------------------------+
void InitSetup2()
  {
   manager2 = new ManagerExpert;
   signal2 = new SignalDunnigan;

   manager2.SetExpiration(2);

   ParamsConfig params;
   params.SetNumber_barras(Num_barras2);
   params.SetTakeProfit(TakeProfit2);
   params.SetPeriod(TimerFrame2);
   params.SetAmplitudeAlvos(AmplitudeAlvo2);
   params.SetAmplitude_movimento(AmplitudeMovimento2);

   InitStup(signal2, manager2, &params);
  }
//+------------------------------------------------------------------+
void InitStup(SignalDunnigan *sig, ManagerExpert *manager,ParamsConfig &params)
  {
   params.m_AmplitudeDoMovimentoRules = m_AmplitudeDoMovimentoRules;
   params.m_AmplitudeAlvosRules = m_AmplitudeAlvosRules;
   params.m_CandleMesmoDiaRules = m_CandleMesmoDiaRules;
   params.m_CandleGatilhoMaiorQueAlvoRules = m_CandleGatilhoMaiorQueAlvoRules;
   params.m_CandleGatilhoRompeuOsDoisLadosRules = m_CandleGatilhoRompeuOsDoisLadosRules;
   params.m_AmplitudeAlvosMaxBarsRules = m_AmplitudeAlvosMaxBarsRules;
   params.m_AmplitudeDoMovimentoMaxBarsRules = m_AmplitudeDoMovimentoMaxBarsRules;

   params.SetLevel_stoploss(LevelStopLoss);
   params.SetStopLoss(StopLoss);

   manager.Init(params.m_period, 123456);
   manager.SetLookingSignalAllDay(true);
   manager.SetHoursLimits(StartAt, EndAt, "17:00");

   sig.SetMinutesLastOperation(15);
   sig.SetParams(&params);
   sig.SetIsReserve(false);
   sig.SetStopLoss(params.m_stop_loss);
   sig.SetTakeProfit(params.m_take_profit);
   manager.InitSignal(sig);

   manager.InitTrailing(trailing);
   manager.InitRisk(risk);
  }
//+------------------------------------------------------------------+
void SendMessage(SignalDunnigan *sig, ManagerExpert *manager, string identy)
  {
   if(sig.isBuy || sig.isSell)
     {
      if(EnviarMessage)
        {
         datetime lastbar_timed=SeriesInfoInteger(Symbol(),sig.m_period,SERIES_LASTBAR_DATE);
         if(sig.m_candle_mensagem_enviada ==0 || sig.m_candle_mensagem_enviada!=lastbar_timed)
           {
            sig.m_candle_mensagem_enviada=lastbar_timed;

            // limita as mensagens no ambiente de dev
            if(MQLInfoInteger(MQL_TESTER) && devQtSend>0)
               return;

            string message = "";
            if(sig.isBuy)
              {
               message ="Buy M" + sig.m_period;
               message +="\nCandle: "+ sig.TimeCurrentBar();
              }
            if(sig.isSell)
              {
               message ="Sell M" + sig.m_period;
               message +="\nCandle: "+ sig.TimeCurrentBar();
              }

            if(MQLInfoInteger(MQL_TESTER))
               message = ">>Test<<\n"+message;

            // pra regular as mensagens no ambiente de dev
            devQtSend++;

            double price, sl, tp=0;
            sig.GetValues(price, sl, tp);
            message += "\nPrice: " + DoubleToString(price, 2);
            message += "\nSl: " + DoubleToString(sl, 2);
            message += "\nTp: " + DoubleToString(tp, 2);

            CArrayString mensagens;
            if(sig.isBuy)
               sig.MessagesConfirmationsBuy(&mensagens);
            if(sig.isSell)
               sig.MessagesConfirmationsSell(&mensagens);

            if(manager.CheckHourDayTrade()==false)
               mensagens.Add("Fora do horário operacional");

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
