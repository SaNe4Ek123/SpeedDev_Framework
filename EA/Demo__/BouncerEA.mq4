

#include "ControllerEA.mqh"

ControllerEA EA;
 
                  
 bool Validate = false;     
 
//+------------------------------------------------------------------+
int OnInit()
  {
   EA.Init();
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    EA.Deinit();
  }
  
   
//+------------------------------------------------------------------+
void OnTick()
  {
     bool spread_filter = Ask - Bid > NormalizeDouble( 80 * Point, Digits );
    if( IsTesting() && !Validate && spread_filter )
        Validate = MarketValidate();
    if( spread_filter )
      return;  
   
    //------------------- Trading GO -----------
     EA.Start();
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
  
  
  

