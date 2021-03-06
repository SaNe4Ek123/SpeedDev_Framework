//+------------------------------------------------------------------+
//|                                              ClassRegression.mqh |
//|                                                           Alex G |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Alex G"
#property link      ""
#property version   "1.00"
#property strict

#include "ClassAccountingOrders.mqh"
#include "ClassOrder.mqh"
#include "../Lib/Array.mqh"

#define REGRESS_TYPE_HIGH      0
#define REGRESS_TYPE_LOW       1
#define REGRESS_TYPE_OPEN      2
#define REGRESS_TYPE_CLOSE     3
#define REGRESS_TYPE_HIGH_LOW  4
#define REGRESS_TYPE_ALL_PRICE 5

#define REGRESS_VALUE_LAST    -1
#define REGRESS_VALUE_FIRST    0

#define DEVIATION_NONE   0
#define DEVIATION_DOWN -1
#define DEVIATION_UP   1

#define REGRESS_DIRECTION_UP  -1
#define REGRESS_DIRECTION_DOWN 1
#define REGRESS_DIRECTION_NONE 0


#define LENEAR 21


//+------------------------------------------------------------------+
class ClassRegression
  {
    public:
      double DistanceToSL,
             iRegress[],
             deviation_up,
             deviation_down;
             
      string symbol;
      int    period,
             timeframe,
             type_price,
             begin_index;

    public:
                     ClassRegression();
                    ~ClassRegression();
              int    InitLenear();
              void   LinearTrailling( int magic = NULL );
              void   Draw();
              double GetValue(int pos, int deviation_type = DEVIATION_NONE);
              int    GetDirection();
              
    private:
              void   ClassRegression::DrawPricePoint( string Name, int Pos, color Color, int deviation_type = DEVIATION_NONE ); 
              double ClassRegression::GetDeviation(int deviation_type);         
              
  };
//+------------------------------------------------------------------+
void ClassRegression::ClassRegression()
  {
     this.DistanceToSL = 0;
     this.begin_index  = 1;
     this.period       = 24;
     this.symbol       = _Symbol;
     this.timeframe    = PERIOD_CURRENT;
     this.type_price   = REGRESS_TYPE_HIGH_LOW;
  
  }
//+------------------------------------------------------------------+
void ClassRegression::~ClassRegression()
  {
  }
//+------------------------------------------------------------------+


//+----------------------------------------------------+
 /**
     Расчёт канала регрессии
 */
 int ClassRegression::InitLenear()
  {   
    double price[];
    if( Bars > this.period + this.begin_index )
      for( int i=this.begin_index; i<this.period + this.begin_index; i++ )
        {
        
          double set_price = 0;
          switch( this.type_price )
            {
              case REGRESS_TYPE_HIGH:      { set_price = High[i]; break; }
              case REGRESS_TYPE_LOW:       { set_price = Low[i]; break; }
              case REGRESS_TYPE_CLOSE:     { set_price = Close[i]; break; }
              case REGRESS_TYPE_OPEN:      { set_price = Open[i]; break; }
              case REGRESS_TYPE_HIGH_LOW:  { set_price = (High[i] + Low[i]) / 2; break; }
              case REGRESS_TYPE_ALL_PRICE: { set_price = (High[i] + Low[i] + Open[i] + Close[i]) / 4; break; }
              default: set_price = 0;
            }
            
          ArrayPush( price, set_price );  
        }
      
    if( ArraySize( price ) == 0 )
      return(0);  
      
    double x_sum      = 0,
           y_sum      = 0,
           xy_sum     = 0,
           x_sqr_sum  = 0,
           n          = ArraySize(price);
           
   for( int x=0; x<ArraySize( price ); x++ )
     {
       x_sum     += x;
       y_sum     += price[x];
       xy_sum    += x * price[x];
       x_sqr_sum += x * x;
     }        
    
    double a = ( y_sum * x_sqr_sum - x_sum * xy_sum )/( n * x_sqr_sum - x_sum * x_sum ),
    
           b = ( n*xy_sum - x_sum * y_sum )/( n * x_sqr_sum - x_sum * x_sum );
    
    ArrayFree( this.iRegress );
    for( int x=0; x<ArraySize( price ); x++ )
      ArrayPush( this.iRegress, ( a + b * x ) );
      
      
   //--- Расчёт отклонений   
    this.deviation_down = 0;
    this.deviation_up   = 0;              
    for( int i=0; i<ArraySize( this.iRegress ); i++ )
      {
        double temp_dev = MathAbs( this.GetValue(i) - High[ this.begin_index + i ] );
        if( temp_dev > this.deviation_up )
          this.deviation_up = temp_dev;
          
        temp_dev = MathAbs( this.GetValue(i) - Low[ this.begin_index + i ] );
        if( temp_dev > this.deviation_down )
          this.deviation_down = temp_dev;
      }   
      
    return( ArraySize( this.iRegress ) );  
 
  }
  
  
//+--------------------- Trailling stop regress ------------------------------+  
 void ClassRegression::LinearTrailling( int magic )
   {   
     double regress = this.GetValue(1);
       if( regress == 0 ) return;
       
       
     double chanel_size = ( High[ iHighest( this.symbol, this.timeframe, MODE_HIGH, this.period, this.begin_index ) ] 
                          - 
                           Low[ iLowest( this.symbol, this.timeframe, MODE_LOW, this.period, this.begin_index ) ]),
                
            delta = chanel_size / 2,           
            border_high = regress + delta,
            border_low =  regress - delta;
           
     
     //--- перебераем все ордера
      ClassOrder order;
      ClassAccountingOrders orders;
      int tickets[];
      
      orders.Init( this.symbol, magic );
      orders.GetTickets( tickets, OP_MARKET );
      
      for( int i=0; i<ArraySize( tickets ); i++ )
        {
          order.Init( tickets[i] );
          
          
          if( order.Type == OP_BUY )
            //order.StopLoss = regress - Settings.DistanceToSL * _Point;
            order.StopLoss = border_low - this.DistanceToSL * _Point;
            
            
          if( order.Type == OP_SELL )
            //order.StopLoss = regress + Settings.DistanceToSL * _Point;
            order.StopLoss = border_high + this.DistanceToSL * _Point;
            
          order.Modify();  
        }   
   }
   
//+----------------------------------------------------------------------------+
 double ClassRegression::GetValue(int pos, int deviation_type = DEVIATION_NONE)
   {    
     if( ArraySize( this.iRegress ) < pos+1 )
       return 0;
     
    //--- Проверка того, что передали
     if( pos == REGRESS_VALUE_FIRST ) 
       pos = 0;
     else if( pos == REGRESS_VALUE_LAST )
       {
         if( ArraySize( this.iRegress ) > 0 )
           pos = ArraySize(this.iRegress) - 1;
       }
     else if( ArraySize( this.iRegress ) >= pos )
       pos = pos - 1;
       
     else return 0;
     
     return this.iRegress[ pos ] + this.GetDeviation( deviation_type );
     
   }   
   
   
//+-------------------------------------------------------+
 double ClassRegression::GetDeviation(int deviation_type)
   {
    switch( deviation_type )
      {
        case DEVIATION_NONE:  {return 0;}
        case DEVIATION_DOWN: {return -this.deviation_down;}
        case DEVIATION_UP:  {return this.deviation_up;}
      }
      
    return 0;  
   }   
   
//+--------------------------------------------------------+
 int ClassRegression::GetDirection()
  {
    double pos_last  = this.GetValue( REGRESS_VALUE_LAST ),
           pos_first = this.GetValue( REGRESS_VALUE_FIRST );
           
    if( pos_first < pos_last )
      return REGRESS_DIRECTION_DOWN;
    
    if( pos_first > pos_last )
      return REGRESS_DIRECTION_UP;
         
   return REGRESS_DIRECTION_NONE;
   
  }
   
   
//=================== Drawing Method ======================

 void ClassRegression::Draw()
  {  
    string prefix = "Regression_"; 
    string NameLine = "Line_",   
           NameHigh = "High_",
           NameLow  = "Low_";
       
    string name = "";       
    for( int i=0; i<ArraySize( this.iRegress ); i++ )
      {
       //--- Линия регрессии 
        name = prefix + NameLine + IntegerToString( i+1 );
        this.DrawPricePoint( name, this.begin_index + i, clrRed );
        
        
       //--- Верхняя граница 
        name = prefix + NameHigh + IntegerToString( i+1 );
        this.DrawPricePoint( name, this.begin_index + i, clrBlue, DEVIATION_UP );
        
       //--- Нижняя граница 
        name = prefix + NameLow + IntegerToString( i+1 );
        this.DrawPricePoint( name, this.begin_index + i, clrBlue, DEVIATION_DOWN );
        
        
      }
           
  }
  
//+------------------------------------------------------------------------------+
 void ClassRegression::DrawPricePoint( string Name, int Pos, color Color, int deviation_type = DEVIATION_NONE )
   {
    double price1 = 0,
           price2 = 0;
           
    if( Pos < 0 )
      return;
    
    if( ArraySize( this.iRegress ) < Pos+1 )
      return;
      
    if( Pos == 0 )
      {
        price1 = this.iRegress[Pos] + GetDeviation( deviation_type );
        price2 = this.iRegress[Pos] + GetDeviation( deviation_type );
      }
    else
      {
        price1 = this.iRegress[Pos] + GetDeviation( deviation_type );
        price2 = this.iRegress[Pos-1] + GetDeviation( deviation_type );
      }
   
    ObjectDelete( Name );
    ObjectCreate( Name, OBJ_TREND, 0, Time[Pos+1], price1, Time[Pos], price2 );
    ObjectSet(Name, OBJPROP_COLOR, Color);
    ObjectSet( Name, OBJPROP_RAY, false );
    
   } 
   
   
//+--------------------------------------------------------------------------