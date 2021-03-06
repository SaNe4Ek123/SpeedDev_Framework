//+------------------------------------------------------------------+
//|                                         ClassInfoPanelProfit.mqh |
//|                                                           Alex G |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Alex G"
#property link      ""
#property version   "1.00"
#property strict

#include "ClassPanel.mqh"
#include "ClassProfit.mqh"
#include "../Orders/ClassAccountingOrders.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ClassInfoPanelProfit
  {
    private:
      string name, default_name, prefix;
      string day_curency_name,
             day_percent_name,
             day_pips_name,
             week_curency_name,
             week_percent_name,
             week_pips_name,
             month_curency_name,
             month_percent_name,
             month_pips_name,
             
             balance_name,
             equity_name,
             total_profit_percent_name,
             total_profit_curency_name,
             load_deposit_name,
             count_orders_name,
             process_unload_name;
             
             
      double day_curency,
             day_percent,
             day_pips,
             week_curency,
             week_percent,
             week_pips,
             month_curency,
             month_percent,
             month_pips;
             
      bool ProcessUnload;
             
       ClassPanel ProfitPanel;
       
       ClassProfit ProfitDay,
                   ProfitWeek,
                   ProfitMonth;
                   
       ClassAccountingOrders Orders;
      

    public:
                     ClassInfoPanelProfit();
                    ~ClassInfoPanelProfit();
               void  Create(string name_);  
               void  Update( string symbol_, int magic_ );
               void  Delete();
               void  SetProcessUnload( bool set );
               
               
    private:   
               color  GetColor( double value );
               void   Init( string name_ );
               string GetObjNameFromPanel();
  };
//+------------------------------------------------------------------+
void ClassInfoPanelProfit::ClassInfoPanelProfit()
  {
    this.default_name = "Panel";
    this.Init( this.default_name );
  }
  
  
//+------------------------------------------------------------------+
 void ClassInfoPanelProfit::~ClassInfoPanelProfit()
  {
  }
  
//+------------------------------------------------------------------+  
 void ClassInfoPanelProfit::Init( string name_ = NULL )
  {
    if( name_ == NULL )
      this.name = this.default_name;
    else
      this.name = name_;
      
    this.prefix = this.name + ": ";
    
    this.day_curency_name   = this.prefix + "DayCurency";
    this.day_percent_name   = this.prefix + "DayPercent";
    this.day_pips_name      = this.prefix + "DayPips";
    this.week_curency_name  = this.prefix + "WeekCurency";
    this.week_percent_name  = this.prefix + "WeekPercent";
    this.week_pips_name     = this.prefix + "WeekPips";
    this.month_curency_name = this.prefix + "MonthCurency";
    this.month_percent_name = this.prefix + "MonthPercent";
    this.month_pips_name    = this.prefix + "MonthPips";
    
    this.balance_name              = this.prefix + "Balance";
    this.equity_name               = this.prefix + "Equity";
    this.total_profit_percent_name = this.prefix + "TotalProfitPercent";
    this.total_profit_curency_name = this.prefix + "TotalProfitCurency";
    this.load_deposit_name         = this.prefix + "LoadDeposit";
    this.count_orders_name         = this.prefix + "CountOrders";
    this.process_unload_name       = this.prefix + "ProcessUnload";
    
    this.ProcessUnload = false;
    
    this.day_curency   = 0;
    this.day_percent   = 0;
    this.day_pips      = 0;
    this.week_curency  = 0;
    this.week_percent  = 0;
    this.week_pips     = 0;
    this.month_curency = 0;
    this.month_percent = 0;
    this.month_pips    = 0;
  }
  
//+------------------------------------------------------------------+
 void ClassInfoPanelProfit::Create(string name_ = NULL)
   {
     this.Init( name_ );
     
    //--- Удаляем все элементы панели ( если таковые существуют )
     this.Delete();
     
     string curency = " "+AccountCurrency();
     string percent = " %";
     string pips = " pips";
       
     int y_pos = 5;  
     int step   = 25;
     int margin = 15;  
       
    //--- Рисуем новую панель
     this.ProfitPanel.Create( this.name, 5, 15, 300, 100 );
     //this.ProfitPanel.CreateWriper(ColorToARGB( clrBlack, 24 ));
    
     this.ProfitPanel.SetLable( 5, y_pos, this.prefix + "DayH", "Day:", clrWhite );
     this.ProfitPanel.SetLable( 33, y_pos, this.day_percent_name, "0" + percent, clrWhite );
     this.ProfitPanel.SetLable( 65, y_pos, this.day_curency_name, "0" + curency, clrWhite );
     
     y_pos += step;
     this.ProfitPanel.SetLable( 5, y_pos, this.prefix + "WeekH", "Weekly:", clrWhite );
     this.ProfitPanel.SetLable( 33, y_pos, this.week_percent_name, "0" + percent, clrWhite );
     this.ProfitPanel.SetLable( 65, y_pos, this.week_curency_name, "0" + curency, clrWhite );
     
     y_pos += step;
     this.ProfitPanel.SetLable( 5, y_pos, this.prefix + "MonthH", "Month:", clrWhite );
     this.ProfitPanel.SetLable( 33, y_pos, this.month_percent_name, "0" + percent, clrWhite );
     this.ProfitPanel.SetLable( 65, y_pos, this.month_curency_name, "0" + curency, clrWhite );
     
     y_pos += step + margin;
     this.ProfitPanel.SetLable( 5, y_pos, this.prefix + "BalanceH", "Balance: ", clrWhite );
     this.ProfitPanel.SetLable( 65, y_pos, this.balance_name, "0" + curency, clrWhite );
     
     y_pos += step;
     this.ProfitPanel.SetLable( 5, y_pos, this.prefix + "EquityH", "Equity: ", clrWhite );
     this.ProfitPanel.SetLable( 65, y_pos, this.equity_name, "0" + curency, clrWhite );
     
     y_pos += step;
     this.ProfitPanel.SetLable( 5, y_pos, this.prefix + "TotalProfitH", "Total profit: ", clrWhite );
     this.ProfitPanel.SetLable( 33, y_pos, this.total_profit_percent_name, "0" + percent, clrWhite );
     this.ProfitPanel.SetLable( 65, y_pos, this.total_profit_curency_name, "0" + curency, clrWhite );
     
     y_pos += step;
     this.ProfitPanel.SetLable( 5, y_pos, this.prefix + "LoadDepositH", "Load deposit: ", clrWhite );
     this.ProfitPanel.SetLable( 33, y_pos, this.load_deposit_name, "0" + percent, clrWhite );
     
     //y_pos += step + margin;
     //this.ProfitPanel.SetLable( 5, y_pos, this.prefix + "ProcessUnloadH", "Process unload: ", clrWhite );
     //this.ProfitPanel.SetLable( 40, y_pos, this.process_unload_name, "OFF", clrWhite );
     
     y_pos += step + margin;
     this.ProfitPanel.SetLable( 5, y_pos, this.prefix + "CountOrdersH", "Count orders: ", clrWhite );
     this.ProfitPanel.SetLable( 40, y_pos, this.count_orders_name, "0", clrWhite );     
     
     
     ChartRedraw();
   }

//+--------------------------------------------------------------------+   
 void ClassInfoPanelProfit::Update( string symbol_ = NULL, int magic_ = 0 )
   { 
     string curency = " "+AccountCurrency();
     string percent = " %";
     string pips = " pips";
     
     color set_color = clrNONE;
   
    //-------------- Инициализация профитов ---------------- 
     this.ProfitDay.Init( symbol_, magic_, PROFIT_DAY );
     this.ProfitWeek.Init( symbol_, magic_, PROFIT_WEEK );
     this.ProfitMonth.Init( symbol_, magic_, PROFIT_MONTH );
     
     this.Orders.Init( symbol_, magic_ );
    
    //--- 
     this.day_curency = this.ProfitDay.profit_currency;
     this.day_percent = this.ProfitDay.profit_percent;
     this.day_pips    = this.ProfitDay.profit_pips;
     
     this.ProfitPanel.UpdateLableText( this.day_curency_name, DoubleToString( this.day_curency, 2 )+curency) ;
     this.ProfitPanel.UpdateLableText( this.day_percent_name, DoubleToString( this.day_percent, 2 )+percent) ;
     this.ProfitPanel.UpdateLableText( this.day_pips_name, DoubleToString( this.day_pips, 2 )+pips) ;
     
     set_color = this.GetColor( this.day_curency );
     this.ProfitPanel.UpdateLableTextColor( this.day_curency_name,   set_color );
     this.ProfitPanel.UpdateLableTextColor( this.day_percent_name,   set_color );
     this.ProfitPanel.UpdateLableTextColor( this.prefix + "Day", set_color ); 
     
     
    //--- 
     this.week_curency = this.ProfitWeek.profit_currency;
     this.week_percent = this.ProfitWeek.profit_percent;
     this.week_pips    = this.ProfitWeek.profit_pips;
     
     this.ProfitPanel.UpdateLableText( this.week_curency_name, DoubleToString( this.week_curency, 2 )+curency) ;
     this.ProfitPanel.UpdateLableText( this.week_percent_name, DoubleToString( this.week_percent, 2 )+percent) ;
     
     set_color = this.GetColor( this.week_curency );
     this.ProfitPanel.UpdateLableTextColor( this.week_curency_name,   set_color );
     this.ProfitPanel.UpdateLableTextColor( this.week_percent_name,   set_color );
     this.ProfitPanel.UpdateLableTextColor( this.prefix + "Week", set_color );
     
     
    //--- 
     this.month_curency = this.ProfitMonth.profit_currency;
     this.month_percent = this.ProfitMonth.profit_percent;
     
     this.ProfitPanel.UpdateLableText( this.month_curency_name, DoubleToString( this.month_curency, 2 )+curency) ;
     this.ProfitPanel.UpdateLableText( this.month_percent_name, DoubleToString( this.month_percent, 2 )+percent) ;
     
     set_color = this.GetColor( this.month_curency );
     this.ProfitPanel.UpdateLableTextColor( this.month_curency_name,   set_color );
     this.ProfitPanel.UpdateLableTextColor( this.month_percent_name,   set_color );
     this.ProfitPanel.UpdateLableTextColor( this.prefix + "Month", set_color );
     
     
    //--- Обновление информации о балансе и средствах 
     this.ProfitPanel.UpdateLableText( this.balance_name, DoubleToString(AccountBalance(), 2) + curency);
     this.ProfitPanel.UpdateLableText( this.equity_name, DoubleToString(AccountEquity(), 2) + curency);
     this.ProfitPanel.UpdateLableText( this.total_profit_percent_name, DoubleToString((AccountEquity() / AccountBalance() * 100 - 100), 2) + percent );
     this.ProfitPanel.UpdateLableText( this.total_profit_curency_name, DoubleToString( AccountEquity() - AccountBalance(), 2) + curency );
     this.ProfitPanel.UpdateLableText( this.load_deposit_name, DoubleToString( AccountMargin()/AccountEquity()*100, 2) + percent );
     
     this.ProfitPanel.UpdateLableText( this.count_orders_name, IntegerToString( this.Orders.market ) );
     
     set_color = this.GetColor( AccountEquity() - AccountBalance() );
     this.ProfitPanel.UpdateLableTextColor( this.equity_name, set_color );
     this.ProfitPanel.UpdateLableTextColor( this.prefix + "Equity", set_color );
     
     this.ProfitPanel.UpdateLableTextColor( this.total_profit_curency_name, set_color );
     this.ProfitPanel.UpdateLableTextColor( this.total_profit_percent_name, set_color );
     this.ProfitPanel.UpdateLableTextColor( this.prefix + "TotalProfit", set_color );
     
     string proc = "OFF";
     if( this.ProcessUnload )
       proc = "ON";
     
     this.ProfitPanel.UpdateLableText( this.process_unload_name, proc );
     
     
     ChartRedraw();
     
   }
   

//+-------------------------------------------------------------+   
 void ClassInfoPanelProfit::Delete()
   {
     string name_ = "WWW";
     while( name_ != "" )
       {
         name_ = this.GetObjNameFromPanel();
         ObjectDelete(ChartID(), name_ );
       }
       
     ChartRedraw();
   }
   
//+--------------------------------------------------------------+   
  string ClassInfoPanelProfit::GetObjNameFromPanel()
    {
      string name_;
      
      for( int i=0; i<ObjectsTotal(); i++ )
       {
         name_ = ObjectName( i );
         if( StringFind( name_, this.name ) > -1 )
           return name_;
       }
       
      return "";  
      
    }
   
   
//+----------------------------------------------------+   
 void ClassInfoPanelProfit::SetProcessUnload( bool set )
   {
     this.ProcessUnload = set;
   }
 
   
//------------ PRIVATE METHODS -----------------
//+----------------------------------------------------+
  color ClassInfoPanelProfit::GetColor( double value )
    {
      color color_plus  = clrGreenYellow,
            color_minus = clrOrange,
            color_zero  = clrHoneydew;
           
      if( value > 0 )
        return color_plus;
      
      if( value < 0 )
        return color_minus;
        
      if( value == 0 )
        return color_zero;
        
      return clrNONE;
    
    }