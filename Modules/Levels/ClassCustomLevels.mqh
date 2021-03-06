//+------------------------------------------------------------------+

#property copyright "Alex G"
#property link      ""
#property version   "1.00"
#property strict

#include "../Classes/ClassAccountingOrders.mqh"
#include "../Classes/ClassOrder.mqh"
#include "../Classes/ClassLevel.mqh"
#include "../Lib/Array.mqh"


//+------------------------------------------------------------------+
class ClassCustomLevels
  {
    private:
      ClassLevel Levels[];
      
      color ColorNewLevel,
            ColorTradeLevel,
            ColorCloseLevel;
      
      string prefix_level;
      
      //---------- Methods ----------
                int Add();
                int GetLastLevelID();

    public:
                     ClassCustomLevels();
                    ~ClassCustomLevels();
                bool Create( string obj_name );
                bool Modify( string obj_name );
                bool Delete( string obj_name );
                bool Tracking();
                int  Init();
  };
  
  
//+------------------------------------------------------------------+
ClassCustomLevels::ClassCustomLevels()
  {
    ArrayFree( this.Levels );
    this.prefix_level = "LEVEL_";
    
    this.ColorNewLevel = clrBlue;
    this.ColorTradeLevel = clrGreenYellow;
    this.ColorCloseLevel = clrRed;
  }
  
  
//+------------------------------------------------------------------+
ClassCustomLevels::~ClassCustomLevels()
  {
  }
  
  
  
//+-------------------------------------------------------------------+
  int ClassCustomLevels::GetLastLevelID()
    {
      int lastID = 0;
      for( int i=0; i<ArraySize(this.Levels); i++ )
        {
          if( this.Levels[i].ID > lastID )
            lastID = this.Levels[i].ID;
        }
      return lastID;
    }
    
    
    
//+--------------------------------------------------------------------+
 bool ClassCustomLevels::Create( string obj_name )
  {
    //--- Здесь Создаём новый уровень, когда пользователь нарисовал прямоугольник
    string name = "";
    double price1 = 0, price2 = 0;
    datetime dt1 = 0, dt2 = 0;
    if( StringFind( obj_name, this.prefix_level )==-1 && ObjectType( obj_name ) == OBJ_RECTANGLE )
      {
        //--- Доработать коррекность присвоения идентификаторов уровней. Проверка уникальности...
        int last_id = GetLastLevelID();
        
        int i = this.Add();
        this.Levels[i].ID = last_id + 1;
         
         name = this.prefix_level + IntegerToString( this.Levels[i].ID );
         ObjectSetString(0, obj_name, OBJPROP_NAME, name);
            
        //----- информация о ценовом уровне, добавление уровня
         price1 = ObjectGetDouble( 0, name, OBJPROP_PRICE1 );
         price2 = ObjectGetDouble( 0, name, OBJPROP_PRICE2 );
         
         dt1 = (datetime)(ObjectGetInteger( 0, name, OBJPROP_TIME1 ) );
         dt2 = (datetime)( ObjectGetInteger( 0, name, OBJPROP_TIME2 ) );
            
        this.Levels[i].SetLevel( price1, price2, dt1, dt2 ); 
            
        ObjectSetInteger( 0, name, OBJPROP_TIME1, this.Levels[i].time_begin );
        ObjectSetInteger( 0, name, OBJPROP_TIME2, this.Levels[i].time_end );
        ObjectSetDouble( 0, name, OBJPROP_PRICE1, this.Levels[i].high );
        ObjectSetDouble( 0, name, OBJPROP_PRICE2, this.Levels[i].low );
            
        Print( "Create Level: ID = ", this.Levels[i].ID );
        
        ChartRedraw();
      }
    return false;
  }
 
 
 
//+--------------------------------------------------------------------+
 bool ClassCustomLevels::Modify( string obj_name )
  {
    //--- Здесь модифицируем параметры уровня, когда пользователь модифицировал его на графике
    string name = "";
    double price1 = 0, price2 = 0;
    datetime dt1 = 0, dt2 = 0;
    if( StringFind( obj_name, this.prefix_level )>-1 && ObjectType( obj_name ) == OBJ_RECTANGLE )
      {
        name = obj_name;
        StringReplace( name, this.prefix_level, "" );
            
        int LevelID =(int) StringToInteger( name );
            
            
        for( int i=0; i<ArraySize( this.Levels ); i++ )
          {
            if(this.Levels[i].ID == LevelID)
              {
                 price1 = ObjectGetDouble( 0, obj_name, OBJPROP_PRICE1 );
                 price2 = ObjectGetDouble( 0, obj_name, OBJPROP_PRICE2 );
                           
                 dt1 = StringToTime( TimeToString( ObjectGetInteger( 0, name, OBJPROP_TIME1 ) ) );
                 dt2 = StringToTime( TimeToString( ObjectGetInteger( 0, name, OBJPROP_TIME2 ) ) );
                           
                 this.Levels[i].SetLevel( price1, price2, dt1, dt2 );     
                     
                 Print( "Update Level: ", this.Levels[i].ID );
                 break;
               }
           }
           
         ChartRedraw();  
       }      
          
    return false;
  }
 
 
 
//+--------------------------------------------------------------------+
 bool ClassCustomLevels::Delete( string obj_name )
  {
    //--- Здесь удаляем уровень, когда пользователь удалил его с графика
    string name = "";
    if( StringFind( obj_name, this.prefix_level )>-1 )
      {
        name = obj_name;
        StringReplace( name, this.prefix_level, "" );
          
        int LevelID =(int) StringToInteger( name );
           
        Print( "Delete Level: ", LevelID );
                
        this.Init();
            
      }      
    return false;
  }
  
     

//+--------------------------------------------------------------------+
 int ClassCustomLevels::Add()
  {
    int size = ArraySize( this.Levels );
    ArrayResize( this.Levels, size+1 );
  
    return size;
  }
  
    
    
    
//+--------------------------------------------------------------------+
 bool ClassCustomLevels::Tracking()    
  {
    //--- Здесь отслежываем установленные уровни и открываем ордера
  
    return false;
  }
 
 
//+------------------------------------------------------------------+
 int ClassCustomLevels::Init()
    {
      ArrayFree( this.Levels );
    
      double price1, price2;
      datetime dt1, dt2;  
      
      if( ObjectsTotal() == 0)
        return 0;
        
      for( int i=0; i<ObjectsTotal(); i++ )
        {
          string name = ObjectName( 0, i );
          if( StringFind( name, this.prefix_level ) == -1 || ObjectType( name ) != OBJ_RECTANGLE )
            continue;
          
          //--- Доработать коррекность присвоения идентификаторов уровней. Проверка уникальности...
            int x = this.Add();
            
            string id_name = name;
            StringReplace( id_name, this.prefix_level, "" );
            
            int LevelID =(int) StringToInteger( id_name );
            
            this.Levels[x].ID = LevelID;
             
            
            //----- информация о ценовом уровне, добавление уровня
             price1 = ObjectGetDouble( 0, name, OBJPROP_PRICE1 );
             price2 = ObjectGetDouble( 0, name, OBJPROP_PRICE2 );
            
             dt1 = (datetime)(ObjectGetInteger( 0, name, OBJPROP_TIME1 ));
             dt2 = (datetime)( ObjectGetInteger( 0, name, OBJPROP_TIME2 ));
            
            this.Levels[x].SetLevel( price1, price2, dt1, dt2 ); 
            
            ObjectSetInteger( 0, name, OBJPROP_TIME1, this.Levels[x].time_begin );
            ObjectSetInteger( 0, name, OBJPROP_TIME2, this.Levels[x].time_end );
            
            
           //--- Определение проторгованности уровня
            color ColorLevel = (color)(ObjectGetInteger( 0, name, OBJPROP_COLOR ));
            if(  ColorLevel == ColorCloseLevel)
              {
                this.Levels[x].Close_ = true;
                this.Levels[x].Trade_ = true;
                this.Levels[x].New_ = true;
              } 
              
            if(  ColorLevel == ColorTradeLevel)
              {
                this.Levels[x].Trade_ = true;
                this.Levels[x].New_ = true;
              }
              
            if(  ColorLevel == ColorNewLevel)
              this.Levels[x].New_ = true;
               
        }
        
     Print( ArraySize( this.Levels ), " levels found" );   
     return ArraySize( this.Levels );
   }