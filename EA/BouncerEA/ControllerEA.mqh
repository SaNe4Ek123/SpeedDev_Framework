
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
         bool OpenOrders( int type_ );
         bool CheckZigZagPattern( int type );



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
    this.ZigZag.SetTimeframe( this.Settings.Timeframe );
    this.ZigZag.SetPeriodZZ( 12 );
    this.ZigZag.SetBars( 500 );
    
    
    
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
    
    //--- Отслеживаем новую свечу 
     this.NewCandleInit();
     
     
    //--- Если свеча новая, то анализируем торговлю 
     if( this.newCandle )
      {
         if( this.AllowedTrade( OP_BUY ) )
            this.OpenOrders( OP_BUY );
            
            
         if( this.AllowedTrade( OP_SELL ) )
            this.OpenOrders( OP_SELL );
      }  
     
     
   }
   
   
//+=============== SERVICE FUNCTION ===================+   
bool ControllerEA::AllowedTrade( int type )
   {
    //--- Проверка паттерна структуры ЗигЗага  
    
     if( ! this.CheckZigZagPattern( type ) )
      return false;
      
    //--- Инициализация учёта ордеров 
     this.Trade.Init();
     
     
    //--- Создание списка Свечей 
     ClassCandle candle[];
     ArrayResize( candle, 10 );
     
     for( int i=0; i<ArraySize( candle ); i++ )
      candle[i].Init( this.Settings.Symbol, this.Settings.Timeframe, i );
      
      
     //--- Получение разрешение на торговлю
      switch( type )
        {
         case OP_BUY:
           {
            return(
                 this.Trade.AccountOrders.buy == 0
              && this.Trade.AccountOrders.buystop == 0   
              && this.Trade.AccountOrders.buylimit == 0
            );
           }
           
           
         case OP_SELL:
           {
            return(
                 this.Trade.AccountOrders.sell == 0
              && this.Trade.AccountOrders.sellstop == 0   
              && this.Trade.AccountOrders.selllimit == 0
            );
           }
        }
        
      return false;  
   }   
   
   
//+------------------------------------------------+
 bool ControllerEA::OpenOrders( int type_ )
   {
      ClassOrder *order = this.Trade.SetOrder();
      
      order.Symbol      = this.Settings.Symbol;
      order.MagicNumber = this.Settings.Input.Magic;
      order.Slippage    = this.Settings.Input.Slippage;
      order.Lot         = this.Settings.Input.Lot;
      
      
      double dist_sl = MathAbs(this.ZigZag.Levels[1].level_low - this.ZigZag.Levels[2].level_high) / 100 * this.Settings.Input.DistanceToSL;
      double dist_impulse = MathAbs(this.ZigZag.Levels[1].level_low - this.ZigZag.Levels[2].level_high);
      
     //--- 
      if( type_ == OP_BUY )
         {  
            order.StopLoss   = this.ZigZag.Levels[2].level_low - dist_sl;
            order.TakeProfit = this.ZigZag.Levels[2].level_low + dist_impulse * (300 / 100);
            
           //--- #1 
            order.Type = OP_BUYLIMIT;
            order.OpenPrice = this.ZigZag.Levels[2].level_low;
            order.Send();
            
           //--- #2 
            order.Type = OP_BUYLIMIT;
            order.OpenPrice = this.ZigZag.Levels[2].level_high;
            order.Send();
            
           //--- #3 
           // order.Type = OP_BUYLIMIT;
           // order.OpenPrice = this.ZigZag.Levels[2].level_low;
           // order.Send();
            
         }
       
      //---  
       if( type_ == OP_SELL )
         {
            order.StopLoss   = this.ZigZag.Levels[2].level_high + dist_sl;
            order.TakeProfit = this.ZigZag.Levels[2].level_high - dist_impulse * (300 / 100);
            
           
           //--- #1 
            order.Type = OP_SELLLIMIT;
            order.OpenPrice = this.ZigZag.Levels[2].level_high;
            order.Send();
           
           //--- #2 
            order.Type = OP_SELLLIMIT;
            order.OpenPrice = this.ZigZag.Levels[2].level_low;
            order.Send();
            
           //--- #3 
            //order.Type = OP_SELLLIMIT;
            //order.OpenPrice = this.ZigZag.Levels[2].level_high;
            //order.Send();
         }  
      
      
      return false;
   }  
  
   
//+------------------------------------------------+
 bool ControllerEA::NewCandleInit(void)
   {
      this.dt_curr = iTime( this.Settings.Symbol, this.Settings.Timeframe, 0 );
      this.newCandle = this.dt_last != this.dt_curr;
      
      this.dt_last = this.dt_curr;
   
      return this.newCandle;
   }
   
   
   
//+------------------------------------------------+
 bool ControllerEA::CheckZigZagPattern( int type )
   {
     this.ZigZag.Init();
     
     if( ArraySize( this.ZigZag.Levels ) < 5 )
      return false;
     
     double dist_correct = MathAbs(this.ZigZag.Levels[0].level_low - this.ZigZag.Levels[1].level_high);
     double dist_impulse = MathAbs(this.ZigZag.Levels[1].level_low - this.ZigZag.Levels[2].level_high);
     
     switch( type )
      {
        //-----
         case OP_BUY: 
            {
               return(
                     this.ZigZag.Levels[0].type == ZZ_LOW
                  && this.ZigZag.Levels[1].level_high > this.ZigZag.Levels[3].level_high
                  && this.ZigZag.Levels[2].level_low >= this.ZigZag.Levels[4].level_low
                  //&& dist_correct / dist_impulse * 100 >= 35
                  
               );
            }
            
        //-----    
         case OP_SELL:
            {
               return(
                     this.ZigZag.Levels[0].type == ZZ_HIGH
                  && this.ZigZag.Levels[1].level_high < this.ZigZag.Levels[3].level_high
                  && this.ZigZag.Levels[2].level_low <= this.ZigZag.Levels[4].level_low
                  //&& dist_correct / dist_impulse * 100 >= 35
                  
               );
            }
      }
     
     return false;
   }