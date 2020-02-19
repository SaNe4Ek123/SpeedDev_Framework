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

//====================== Глобальные переменные =======================

 bool newCandle = false;
 datetime dt_last = 0,
          dt_curr = 0;
          
 string NameEA, Email, AuthorNameFull, AuthorNik;   
          
 bool Validate = false;     
 
//+------------------------------------------------------------------+
int OnInit()
  {
    NameEA = "Trender EA";
    
   //--- Инициализация настроек 
    SettingsInit();
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
void OnTick()
  {
    bool spread_filter = Ask - Bid > NormalizeDouble( 80 * Point, Digits );
    if( IsTesting() && !Validate && spread_filter )
        Validate = MarketValidate();
    if( spread_filter )
      return;  
  
     
  }



  
//--------- Validate To Market -------------
bool MarketValidate(  )
  {
   //---------------------- 
    ClassOrder order;
    int t;
    
    order.Lot = 1;
    order.Type = OP_BUY;
    order.OpenPrice = MarketInfo( Symbol(), MODE_ASK );
    order.StopLoss  = order.OpenPrice - 200*_Point;
    order.TakeProfit = order.OpenPrice + 200*_Point;
    order.Slippage = 1;
     
    t = order.Send();
    if( t > 0 && OrderSelect( t, SELECT_BY_TICKET, MODE_TRADES ) )
      if( OrderClose( t, OrderLots(), MarketInfo( Symbol(), MODE_BID ), 10 ) )
          return true; 
        
    return false;
  }     