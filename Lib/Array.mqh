
//-------- Добавление элементов в массив --------
void ArrayPush( double &array[], double value )
   {
     int size = ArraySize(array);
     ArrayResize(array, size + 1);
     
     array[size] = value;
   }   
   
   
void ArrayPush( string &array[], string value )
   {
     int size = ArraySize(array);
     ArrayResize(array, size + 1);
     
     array[size] = value;
   }   
   
void ArrayPush( int &array[], int value )
   {
     int size = ArraySize(array);
     ArrayResize(array, size + 1);
     
     array[size] = value;
   }   

   
   
   
   
   
   
//+---------- Перенаправление индексации ----------+
 int ArrayReverse( double &Arr[] )
   { 
     if( ArraySize( Arr ) == 0 )
       return 0;
       
     double NewArr[];
     int index = 0;
     for( int i=ArraySize( Arr ); i>0; i-- )
       {
         if( ArraySize( NewArr ) < i )
           ArrayResize( NewArr, i );
           
         NewArr[index] = Arr[i-1];
         index++;
       }
     
     if( ArraySize( NewArr ) > 0 )
       {
         ArrayFree( Arr );
         ArrayCopy(Arr, NewArr);
         return( ArraySize( Arr ) );
       } 
       
     return 0;
   }    
   
   
//---- Searching --------
 int ArraySearch( string &array[], string value )
   {
     for( int i=0; i<ArraySize( array ); i++ )
      if( array[i] == value )
         return i;
         
     return -1;
   }     
   
   
int ArraySearch( int &array[], int value )
   {
     for( int i=0; i<ArraySize( array ); i++ )
      if( array[i] == value )
         return i;
         
     return -1;
   }        
   
   