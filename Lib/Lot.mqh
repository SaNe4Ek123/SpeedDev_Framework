//+------------------------------------------------------------------+
//|                                                          Lot.mqh |
//|                                                           Alex G |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Alex G"
#property link      ""
#property strict



//+------------------------------------------------+
  double GetLot( double lot, double balance, double min_lot = 0.01 )
    {
      double new_lot;
    
      if( balance > 0 && lot > 0 )
        new_lot = NormalizeDouble( AccountBalance()/balance*lot, 2 );
      else
        new_lot = lot;
    
      if( lot  < min_lot )
        new_lot = min_lot;
      
      if( new_lot > 99)
       new_lot = 99;
      
     
      return new_lot;
    }
    
//+------------ Лот без уменьшения ----------------+
  double GetLotMax( double lot, double balance, double &last_lot, double min_lot = 0.01 )
    {
      double curr_lot = GetLot( lot, balance );
      if( curr_lot > last_lot )
       last_lot = curr_lot;
      
      return last_lot;
   }
   
//+------------ Лот по размеру стоплосса ( % от баланса на сделку ) ----------------+
 double GetLotForPercentFromBalance( double StopLoss, double MaxRisk, bool  )
   {
      double Free    =AccountFreeMargin();
      double LotVal  =MarketInfo(Symbol(),MODE_TICKVALUE);//стоимость 1 пункта для 1 лота
      double Min_Lot =MarketInfo(Symbol(),MODE_MINLOT);
      double Max_Lot =MarketInfo(Symbol(),MODE_MAXLOT);
      double Step    =MarketInfo(Symbol(),MODE_LOTSTEP);
      double Lot     =MathFloor((Free*MaxRisk/100)/(StopLoss*LotVal)/Step)*Step;
      if(Lot<Min_Lot) Lot=Min_Lot;
      if(Lot>Max_Lot) Lot=Max_Lot;
      return Lot;
   }