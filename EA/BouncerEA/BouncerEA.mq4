//+------------------------------------------------------------------+
//|                                                        BoxEA.mq4 |
//|                                                           Alex G |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Alex G"
#property link      ""
#property version   "1.00"
#property strict

#include "IncHeader.mqh"
#include "Settings.mqh"

#include "..\..\Modules\ClassTrade.mqh"
#include "..\..\Modules\Class.mqh"

//====================== Глобальные переменные =======================
   
 string NameEA, Email, AuthorNameFull, AuthorNik;   
 
 ClassTrade Trade;
          
 
  
 bool newCandle = false;
 datetime dt_last = 0,
          dt_curr = 0;  
                  
 bool Validate = false;     
 
//+------------------------------------------------------------------+
int OnInit()
  {
    NameEA = "Trender EA";
    
   //--- Инициализация настроек 
    SettingsInit();
    Trade.Create( Settings.Symbol, Settings.Input.Magic );
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
  
  
void Main()
   {
     
    bool spread_filter = Ask - Bid > NormalizeDouble( 80 * Point, Digits );
    if( IsTesting() && !Validate && spread_filter )
        Validate = MarketValidate();
    if( spread_filter )
      return;  
      
   
    dt_curr = iTime( Settings.Symbol, Settings.Timeframe, 0 );
    newCandle = dt_last != dt_curr; 
     
     
     
     
   }     
   
   
   
 
 
   
   
//+------------------------------------------------------------------+
void OnTick()
  {
     Main();
  }
  
//--------- Validate To Market -------------
bool MarketValidate(  )
  {
   //---------------------- 
    ClassOrder order;
    
    order.Lot = 1;
    order.Type = OP_BUY;
    order.OpenPrice = MarketInfo( Symbol(), MODE_ASK );
    order.StopLoss  = order.OpenPrice - 200*_Point;
    order.TakeProfit = order.OpenPrice + 200*_Point;
    order.Slippage = 1;
     
    order.Send();
    order.Close();
        
    return false;
  }     
  
  
  

