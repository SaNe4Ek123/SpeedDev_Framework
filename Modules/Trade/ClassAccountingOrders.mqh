//+------------------------------------------------------------------+
//|                                        ClassAccountingOrders.mqh |
//|                                                           Alex G |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Alex G"
#property link      ""
#property version   "1.00"
#property strict

#define OP_MARKET 10
#define OP_DEFERREND 20
#define OP_ALL 30
//+------------------------------------------------------------------+
class ClassAccountingOrders
  {
    public:
      int market,
          deferrend,
          buy,
          sell,
          buystop,
          sellstop,
          buylimit,
          selllimit,
          all;
          
    private:
      int tickets_buy[], 
          tickets_sell[],
          tickets_buystop[],
          tickets_sellstop[],
          tickets_buylimit[],
          tickets_selllimit[],
          tickets_market[],
          tickets_deferrend[],
          tickets_all[];
            
  
    

    public:
                         ClassAccountingOrders();
                        ~ClassAccountingOrders();
                        
                   void  Clear();
                   void  Init(string symbol_, int magic_ );
                   void  ShowCountOrders();
                   void  GetTickets( int &tickets[], int type );
                   
    private:       void  SaveTicket( int &arr[], int ticket );
  };
//+------------------------------------------------------------------+
ClassAccountingOrders::ClassAccountingOrders()
  {
    this.Clear();
  }
  
  
//+------------------------------------------------------------------+
ClassAccountingOrders::~ClassAccountingOrders()
  {
    this.Clear();
    Comment( "" );
  }
  
  
//+------------------------------------------------------------------+
void ClassAccountingOrders::Clear()
  {
    this.all       = 0;
    this.market    = 0;
    this.deferrend = 0;
    this.sell      = 0;
    this.selllimit = 0;
    this.sellstop  = 0;
    this.buy       = 0;
    this.buylimit  = 0;
    this.buystop   = 0;
    
    ArrayFree( this.tickets_buy );
    ArrayFree( this.tickets_sell );
    ArrayFree( this.tickets_buystop );
    ArrayFree( this.tickets_sellstop );
    ArrayFree( this.tickets_buylimit );
    ArrayFree( this.tickets_selllimit );
    ArrayFree( this.tickets_market );
    ArrayFree( this.tickets_deferrend );
    ArrayFree( this.tickets_all );
  }
  
//+--------------------------------------------------------------------+
void ClassAccountingOrders::Init(string symbol_ = NULL, int magic_ = NULL )
  {
    this.Clear();
    
    if(OrdersTotal() == 0)
      return;
            
          
    for(int i=0; i<OrdersTotal(); i++)
      {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
          {
                
           //--- Проверка выбранного ордера исходя из условий
            bool selected;
            if( symbol_ != NULL && magic_ != NULL )
              selected = ( OrderMagicNumber() == magic_ && OrderSymbol() == symbol_ );
                    
            if( symbol_ != NULL && magic_ == NULL )
              selected = ( OrderSymbol() == symbol_ );
              
            if( symbol_ == NULL && magic_ != NULL )
              selected = ( OrderMagicNumber() == magic_ );
              
            if( symbol_ == NULL && magic_ == NULL )
              selected = true;
                    
                    
            if( selected )
              {
                switch( OrderType() )
                  {
                    case OP_BUY:       {this.all++; this.market++;    this.buy++;  this.SaveTicket( this.tickets_buy,  OrderTicket() ); this.SaveTicket( this.tickets_market,  OrderTicket() ); this.SaveTicket( this.tickets_all,  OrderTicket() ); break;}
                    case OP_SELL:      {this.all++; this.market++;    this.sell++; this.SaveTicket( this.tickets_sell, OrderTicket() ); this.SaveTicket( this.tickets_market,  OrderTicket() ); this.SaveTicket( this.tickets_all,  OrderTicket() ); break;}
                    case OP_BUYSTOP:   {this.all++; this.deferrend++; this.buystop++;   this.SaveTicket( this.tickets_buystop, OrderTicket() ); this.SaveTicket( this.tickets_deferrend,  OrderTicket() ); this.SaveTicket( this.tickets_all,  OrderTicket() ); break;}
                    case OP_SELLSTOP:  {this.all++; this.deferrend++; this.sellstop++;  this.SaveTicket( this.tickets_sellstop, OrderTicket() ); this.SaveTicket( this.tickets_deferrend,  OrderTicket() ); this.SaveTicket( this.tickets_all,  OrderTicket() ); break;}
                    case OP_BUYLIMIT:  {this.all++; this.deferrend++; this.buylimit++;  this.SaveTicket( this.tickets_buylimit, OrderTicket() ); this.SaveTicket( this.tickets_deferrend,  OrderTicket() ); this.SaveTicket( this.tickets_all,  OrderTicket() ); break;}
                    case OP_SELLLIMIT: {this.all++; this.deferrend++; this.selllimit++; this.SaveTicket( this.tickets_selllimit, OrderTicket() ); this.SaveTicket( this.tickets_deferrend,  OrderTicket() ); this.SaveTicket( this.tickets_all,  OrderTicket() ); break;}
                  }
              }
          }
      }
  }  
  
  
//+---------------------------------------------------------------------------------------------+
void ClassAccountingOrders::ShowCountOrders()
  {
    Comment ("Покупки ",  this.buy,      "\n",
             "Продажи ",  this.sell,     "\n",
             "BuyLimit ", this.buylimit, "\n",
             "SellLimit ",this.selllimit,"\n",
             "BuyStop ",  this.buystop,  "\n",
             "SellStop ", this.sellstop, "\n",
             "Сделки ",   this.market,   "\n",
             "Отложки ",  this.deferrend,"\n",
             "Всего ",    this.all); 
  }
 
 
//+---------------------------------------------------------------------------------------------+
void ClassAccountingOrders::GetTickets( int &tickets[], int type )
  {
    ArrayFree( tickets );
    
    switch( type )
      {
        case OP_BUY:      { ArrayCopy( tickets, this.tickets_buy ); break; }
        case OP_SELL:     { ArrayCopy( tickets, this.tickets_sell ); break; }
        case OP_BUYSTOP:  { ArrayCopy( tickets, this.tickets_buystop ); break; }
        case OP_SELLSTOP: { ArrayCopy( tickets, this.tickets_sellstop ); break; }
        case OP_BUYLIMIT: { ArrayCopy( tickets, this.tickets_buylimit ); break; }
        case OP_SELLLIMIT:{ ArrayCopy( tickets, this.tickets_selllimit ); break; }
        
        case OP_MARKET:   { ArrayCopy( tickets, this.tickets_market ); break; }
        case OP_DEFERREND:{ ArrayCopy( tickets, this.tickets_deferrend ); break; }
        case OP_ALL:      { ArrayCopy( tickets, this.tickets_all ); break; }
      }
    
  }
 


//--- PRIVATE METHODS  
//+---------------------------------------------------------------------------------------------+
void ClassAccountingOrders::SaveTicket( int &arr[], int ticket )
  {
    int size = ArraySize( arr );
    ArrayResize( arr, size+1 );
    
    arr[ size ] = ticket;
  }  
  
  