//+------------------------------------------------------------------+
//|                                                   ClassOrder.mqh |
//|                                                           Alex G |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Alex G"
#property link      ""
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ClassOrder
  {
    public:
       int ID,
           Ticket,
           MagicNumber,
           Type,
           Slippage;
           
       double OpenPrice,
              StopLoss,
              TakeProfit,
              ClosePrice,
              Lot;
              
       string Comment,
              Symbol;
       
       datetime Experation;
       color Color;
       
       bool Deleted,
            Closed,
            Virtual;
    

    public:
                     ClassOrder();     
                    ~ClassOrder();
                int  Send();
                bool Close( double volume_percent = 100 );
                bool Modify();
                int  Init( string symbol, int magic, string comment = NULL, int type = -1 );
                bool ClassOrder::Init( int ticket );
                void ClassOrder::Clear();
                
    private:
                bool CheckMoneyForTrade(string symbol, double lots,int type);
                bool CheckStopLoss_Takeprofit(int type,double SL,double TP);
  };
  
//+------------------------------------------------------------------+
ClassOrder::ClassOrder()
  {
    this.Clear();
  }
  
  
//+------------------------------------------------------------------+
ClassOrder::~ClassOrder()
  {
  }
  
//+------------------------------------------------------------------+  
 void ClassOrder::Clear()
   {
     this.Ticket      = 0;
     this.MagicNumber = NULL;
     this.Type        = -1;
     this.Slippage    = 10;
     this.Comment     = NULL;
     this.Symbol      = Symbol();
     this.Color       = clrNONE;
     this.Experation  = 0;
     this.StopLoss    = 0;
     this.TakeProfit  = 0;
     this.Lot         = 0;
     this.OpenPrice   = 0;
     this.ClosePrice  = 0;
     this.Deleted     = false;
     this.Closed      = false;
     this.Virtual     = false;
   }
//+------------------------------------------------------------------+
int ClassOrder::Send()
       {
         this.Ticket = 0;
         bool result;
         
         if(this.Type == OP_BUY || this.Type == OP_BUYLIMIT || this.Type == OP_BUYSTOP )
           this.Color = clrBlue;
           
         if(this.Type == OP_SELL || this.Type == OP_SELLLIMIT || this.Type == OP_SELLSTOP )
           this.Color = clrRed;
           
         if(this.Type == OP_BUY )
           this.OpenPrice = Ask;
         if(this.Type == OP_SELL)
           this.OpenPrice = Bid;
           
         
         if( !this.CheckMoneyForTrade( this.Symbol, this.Lot, this.Type ) )
            return false;
               
         if( !this.CheckStopLoss_Takeprofit( this.Type, this.StopLoss, this.TakeProfit ) )
            return false;
            
            
           this.Ticket = OrderSend( this.Symbol,
                                    this.Type,
                                    this.Lot,
                                    this.OpenPrice,
                                    this.Slippage,
                                    0, 0,
                                    this.Comment,
                                    this.MagicNumber,
                                    this.Experation,
                                    this.Color);
                                  
         double open_price;
         if(this.Type == ( OP_BUY || OP_SELL ))
           open_price = 0;
         else
           open_price = this.OpenPrice;
                          
         if(this.Ticket > 0 && ( this.StopLoss > 0 || this.TakeProfit > 0 ) && this.Virtual == false)
           result = OrderModify(this.Ticket, open_price, this.StopLoss, this.TakeProfit, this.Experation, this.Color);
                                  
         
         return this.Ticket;
       }
       

//+---------------------------------------------------------------------------+
bool ClassOrder::CheckMoneyForTrade(string symbol_, double lots_,int type_)
  {
    if( lots_ == 0 )
      return false;
      
    string oper = "";
    switch(type_)
      {
        case(OP_BUY):      { type_ = OP_BUY; oper = "Buy";        break; }
        case(OP_BUYSTOP):  { type_ = OP_BUY; oper = "BuyStop";    break; }
        case(OP_BUYLIMIT): { type_ = OP_BUY; oper = "BuyLimit";   break; }
        case(OP_SELL):     { type_ = OP_SELL; oper = "Sell";      break; }
        case(OP_SELLSTOP): { type_ = OP_SELL; oper = "SellStop";  break; }
        case(OP_SELLLIMIT):{ type_ = OP_SELL; oper = "SellLimit"; break; }
      }
  
    double free_margin=AccountFreeMarginCheck(symbol_,type_,lots_);
   //-- если денег не хватает
    if(free_margin<0)
      {
       Print(DoubleToStr(free_margin)+" lots "+DoubleToStr(lots_)+" type "+IntegerToString(type_)+" Not enough money for ", oper," ",lots_, " ", symbol_, " Error code=",GetLastError());
       return(false);
      }
   //-- проверка прошла успешно
    return(true);
   }
   
   
//+---------------------------------------------------------------------------+
bool ClassOrder::CheckStopLoss_Takeprofit(int type,double SL,double TP)
  {
   
   switch(type)
    {
      case OP_BUYSTOP:  {type = OP_BUY;  break;}
      case OP_BUYLIMIT: {type = OP_BUY;  break;}
      case OP_SELLSTOP: {type = OP_SELL; break;}
      case OP_SELLLIMIT:{type = OP_SELL; break;}
    }  
  
//--- получим уровень SYMBOL_TRADE_STOPS_LEVEL
   int stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(stops_level!=0)
     {
      PrintFormat("SYMBOL_TRADE_STOPS_LEVEL =% d: StopLoss and TakeProfit must be" +
                  "not closer than% d points from the closing price",stops_level,stops_level);
     }
//---
   bool SL_check=false,TP_check=false;
//--- проверяем только два типа ордеров
   switch(type)
     {
      //--- операция покупка
      case OP_BUY:
        {
         //--- проверим StopLoss
         SL_check= (SL == 0) || (this.OpenPrice-SL>stops_level*_Point);
         if(!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be less than %.5f"+
                        " (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(ORDER_TYPE_BUY),SL,this.OpenPrice-stops_level*_Point,this.OpenPrice,stops_level);
         //--- проверим TakeProfit
         TP_check= (TP == 0) || (TP-this.OpenPrice>stops_level*_Point);
         if(!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be greater than %.5f"+
                        " (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(ORDER_TYPE_BUY),TP,this.OpenPrice+stops_level*_Point,this.OpenPrice,stops_level);
         //--- вернем результат проверки
         return(SL_check&&TP_check);
        }
      //--- операция продажа
      case  OP_SELL:
        {
         //--- проверим StopLoss
  
         SL_check= (SL == 0) || (SL-this.OpenPrice>stops_level*_Point);
         if(!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f "+
                        " (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(ORDER_TYPE_SELL),SL,this.OpenPrice+stops_level*_Point,this.OpenPrice,stops_level);
         //--- проверим TakeProfit
         TP_check= (TP == 0) || (this.OpenPrice-TP>stops_level*_Point);
         if(!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be less than %.5f "+
                        " (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(ORDER_TYPE_SELL),TP,this.OpenPrice-stops_level*_Point,this.OpenPrice,stops_level);
         //--- вернем результат проверки
         return(TP_check&&SL_check);
        }
      break;
     }
//--- для отложенных ордеров нужна немного другая функция
   return false;
  }
  
  
  
    
//+---------------------------------------------------------------------------+
 bool ClassOrder::Close( double volume_percent = 100 )
   {
     if( volume_percent < 0 )
       return false;
   
     if( !OrderSelect( this.Ticket, SELECT_BY_TICKET, MODE_TRADES ) )
       return false;
    
    //--- Получаем запрпшиваемый объём для закрытия сделки ---   
     double volume = 0;
     
     if( volume_percent >= 100 ) 
       volume = OrderLots();
       
     if( volume_percent < 100 )
       {
         volume = NormalizeDouble( volume_percent / 100 * OrderLots(), 2 );
         
         if( OrderLots() - volume < 0.01 )
           volume = OrderLots();
           
       }
       
     if( volume > OrderLots() )
       volume = OrderLots();
       
    //--- Получаем цену по которой нужно закрыть сделку
     double close_price = 0;
     
     if( this.Type == OP_BUY )
       close_price = Bid;
     if( this.Type == OP_SELL )
       close_price = Ask;   
     
    //--- Закрываем сделку ---
     if( OrderClose( OrderTicket(), NormalizeDouble( volume, 2 ), NormalizeDouble( close_price, Digits ), this.Slippage, clrGray ) )
       {
         this.Clear();
         return true;
       }
   
     return false;
   }
   
   
//+---------------------------------------------------------------------------+
 bool ClassOrder::Modify()
   {
     bool market_order =    this.Type == OP_BUY 
                         || this.Type == OP_SELL;
     
     bool defferend_order =    this.Type == OP_BUYSTOP 
                            || this.Type == OP_SELLSTOP 
                            || this.Type == OP_BUYLIMIT 
                            || this.Type == OP_SELLLIMIT;
   
    //--- Проверка актуальности тикета и выборка ордера ----
     if( market_order )
       if( !OrderSelect( this.Ticket, SELECT_BY_TICKET, MODE_TRADES ) )
         return false;
         
     if( !this.Virtual && defferend_order )
       if( !OrderSelect( this.Ticket, SELECT_BY_TICKET, MODE_TRADES ) )
         return false;
         
    //--- Проверка наличия изменений
     bool modify = false;
     
     //--
     modify = (
                  ( this.Type == defferend_order && ( NormalizeDouble( OrderOpenPrice(), Digits ) ) != NormalizeDouble( this.OpenPrice, Digits ) )
               || ( NormalizeDouble( OrderStopLoss(), Digits) != NormalizeDouble( this.StopLoss, Digits) )
               || ( NormalizeDouble( OrderTakeProfit(), Digits ) != NormalizeDouble( this.TakeProfit, Digits ) )
               || ( OrderExpiration() != this.Experation )
               
              );
      
     
     if( modify && !this.Virtual )
       {
         double modify_price = 0;
         
         if( defferend_order )
           modify_price = this.OpenPrice;
           
         if( OrderModify( OrderTicket(), modify_price, this.StopLoss, this.TakeProfit, this.Experation ) )
           return true;
           
       }
     
     return false;
   }   
   
//------------ Инициализация последнего ордера ----------------
 int ClassOrder::Init( string symbol_, int magic, string comment = NULL, int type = -1 )
   {
     this.Clear();
     if( OrdersTotal() == 0 )
       return 0;
       
     for( int i=0; i<OrdersTotal(); i++ )
       {
         bool find = false;
         if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) )
           {
             find = (OrderSymbol() == symbol_ && OrderMagicNumber() == magic);
             if( comment !=NULL )
               find = find && OrderComment() == comment;
             
             if( type > -1 && type < 6 )
               find = (OrderSymbol() == symbol_ && OrderMagicNumber() == magic)&& OrderType() == type;
               
               
             if( find )
               {
                 this.Init( OrderTicket() );
               
                 return this.Ticket;
               }
           }
       }
   
     return 0;
   }
   
//------ Инициализация ордера по тикету    
 bool ClassOrder::Init( int ticket )
   {
     this.Clear();
     if( OrderSelect( ticket, SELECT_BY_TICKET, MODE_TRADES ) )
       {    
         this.MagicNumber = OrderMagicNumber();
         this.Symbol      = OrderSymbol();
         this.Type        = OrderType();
         this.Experation  = OrderExpiration();
         this.Lot         = OrderLots();
         this.Slippage    = 10;
         this.Ticket      = OrderTicket();
         this.StopLoss    = OrderStopLoss();
         this.TakeProfit  = OrderTakeProfit();
         this.OpenPrice   = OrderOpenPrice();
         this.Comment     = OrderComment();
         this.Virtual     = false;
               
         return true;
       }
           
     return false;
   }
   
   




