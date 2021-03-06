
#property copyright "AlexG"
#property link      ""
#property version   "1.00"
#property strict

#include "IncHeader.mqh"
#include "Settings.mqh"

#include "..\..\Modules\ClassTrade.mqh"
#include "..\..\Modules\ClassZigZag.mqh"
#include "..\..\Modules\Candles\ClassCandle.mqh"




class ControllerEA
  {
     private:
      ClassTrade Trade;
      ClassZigZag ZigZag;
      ClassSettings Settings;
      
      
      bool newCandle;
      datetime dt_last,          
               dt_curr;   
               
                           
      
      //+--------------------------------------------
         bool AllowedTrade( int type );    
         bool NewCandleInit(); 
         bool OpenOrder( int type );



     public:
                     ControllerEA();
                    ~ControllerEA();
                    
                  void Init();
                  void Deinit();
                  void Start();
  };
//+------------------------------------------------------------------+
ControllerEA::ControllerEA()
  {
    SettingsInit( this.Settings );
    this.Trade.Create( this.Settings.Symbol, this.Settings.Input.Magic );
    
    this.ZigZag.SetSymbol( this.Settings.Symbol );
    this.ZigZag.SetTimeframe( this.Settings.Input.Magic );
    this.ZigZag.SetPeriodZZ( 20 );
    this.ZigZag.SetBars( 150 );
    
    
    
    this.newCandle = false;
    this.dt_last = 0;          
    this.dt_curr = 0; 
    
    
  }
  
  
//+------------------------------------------------------------------+
 void ControllerEA::~ControllerEA()
  {
  }
  
  
//+------------------------------------------------------------------+
 void ControllerEA::Init()
   {
      
   }
   
   

//+------------------------------------------------------------------+
 void ControllerEA::Deinit()
   {
   
   }
   


//+------------------------------------------------------------------+
 void ControllerEA::Start()
   {
     
     this.NewCandleInit();
     
     
     if( this.newCandle )
       this.ZigZag.Init();
       
      
      
     if( this.newCandle ) 
       this.Trade.Init();
       
     if( this.Trade.AccountOrders.all == 0 )
      {
         if( this.AllowedTrade( OP_BUY ) )
            this.OpenOrder( OP_BUYSTOP );
            
         if( this.AllowedTrade( OP_SELL ) )
            this.OpenOrder( OP_SELLSTOP );
      }  
      
     
     this.Trade.TrackOrder(); //--- Отслеживает Ещё не открытый, но уже сформированный ордер
     
     
   }
   
   
//+=============== SERVICE FUNCTION ===================+   
bool ControllerEA::AllowedTrade( int type )
   {
     
     
     ClassCandle candle[];
     ArrayResize( candle, 10 );
     
     for( int i=0; i<ArraySize( candle ); i++ )
      candle[i].Init( this.Settings.Symbol, this.Settings.Timeframe, i );
      
     
      switch( type )
        {
         case OP_BUY:
           {
            return(
                 candle[1].direction == CANDLE_UP
              && candle[2].direction == CANDLE_DOWN 
            );
           }
           
           
         case OP_SELL:
           {
            return(
                 candle[1].direction == CANDLE_DOWN
              && candle[2].direction == CANDLE_UP 
            );
           }
        }
        
      return false;  
   }   
   
   
//+------------------------------------------------+
 bool ControllerEA::OpenOrder( int type )
   {
      double open_price = 0, sl = 0, tp = 0;
      if( type == OP_BUYSTOP )
         {
            open_price = Ask;
            sl = Low[iLowest( this.Settings.Symbol, this.Settings.Timeframe, MODE_LOW, 5, 1 )];
            tp = open_price + ( MathAbs( open_price - sl ) * 2 );
         }
         
       if( type == OP_SELLSTOP )
         {
            open_price = Bid;
            sl = High[iLowest( this.Settings.Symbol, this.Settings.Timeframe, MODE_HIGH, 5, 1 )];
            tp = open_price - ( MathAbs( open_price - sl ) * 2 );
         }  
   
      ClassOrder *order = this.Trade.SetOrder();
      
      order.Symbol      = this.Settings.Symbol;
      order.MagicNumber = this.Settings.Input.Magic;
      order.Type        = type;
      order.OpenPrice   = open_price;
      order.StopLoss    = sl;
      order.TakeProfit  = tp;
      order.Slippage    = this.Settings.Input.Slippage;
      order.Lot         = 0.1;
      
      
      return false;
   }  
  
   
//+------------------------------------------------+
 bool ControllerEA::NewCandleInit(void)
   {
      this.dt_curr = iTime( this.Settings.Symbol, this.Settings.Timeframe, 0 );
      this.newCandle = this.dt_last != this.dt_curr;
   
      return this.newCandle;
   }