//+------------------------------------------------------------------+
//|                                           Beautiful Duckling.mq4 |
//|                                Copyright � 2014, Damian Miriello |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2014, Damian Miriello"
/*
Beautiful Duckling Filtered Zones

13.2 Rev

ToDo:
Remove iCustom to only look at PTZ's

*/
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


extern bool Trade=true; //Stops trading but doesn't flatten
extern int RZ= 30; //Right-zone
extern int LZ= 30; //Left-zone
extern int EZ= 30; //Exit-zone
extern int tf = 1;
extern double Lots=0.05; //Lots per trade
extern double SSpr = 1; //Spacing between trades
extern double Offset = 0; //How far against the first signal before taking first trade
//extern int MaxBars=1000; //Lookback to find Confirmed Zone
extern double Digs = 10; //Digit multiplier, i.e. for ChfPln etc Digs=1
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int LMag, SMag, EMag;
double HiZ2, LoZ2, EP;
bool Long, Short;
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

int init(){
SSpr=SSpr*Digs*Point; Offset=Offset*10*Point;
Alert(Symbol()," GoWithLZ Multi LZ/RZ/TF/Lots/SSpr: ",LZ,"/",RZ,"/",tf,"/",Lots,"/",SSpr);
CheckStatus();

}//init
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


int start(){

if(Trade){

if(EMag>0){Exit();}

if(EMag==0){
   if(!Long && !Short){
      HiZ2=0; LoZ2=0;
      FindUnConfZone();
      if(HiZ2>0){IfHi();}//if last was UnConf Lo (NoTrade) or Conf Hi (Trade)
      if(LoZ2>0){IfLo();}
   }
   
   //if(!Long && !Short){Trader();}
   if(Short || Long){
      Handler();
      if(LMag==0 && SMag==0){
         FindUnConfZone2();
         if(Short && HiZ2>0){EMag=LZ*tf; HiZ2=0; LoZ2=0; Alert(Symbol()," Kill Shorts");}
         if(Long && LoZ2>0){EMag=LZ*tf; LoZ2=0; HiZ2=0; Alert(Symbol()," Kill Longs");}
      }
   }
   
      if(LMag>0){DoGoLong(LMag);}
      if(SMag>0){DoGoShort(SMag);}
}//emag

}//trade
if(!Trade){KillEverything();}
}//start
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void IfHi(){
//double x,y,n;
//x=0;y=0;n=0;
//always has value of last time it hit?
//if so, how to find what candle it was from? New buffer with i value...
//for (int i=0;i<MaxBars;i++){
//   x=iCustom(Symbol(),tf,"FilteredZones2.0",LZ,RZ,0,i);//Conf Up
//   y=iCustom(Symbol(),tf,"FilteredZones2.0",LZ,RZ,1,i);//Conf Dn
   //double z=iCustom(Symbol(),tf,"FilteredZones",2,i);//UnConf Up
//   n=iCustom(Symbol(),tf,"FilteredZones2.0",LZ,RZ,3,i);//UnConf Dn
//   if(x>0 || y>0 || n>0){break;}
//}

//if(x>0){
      Long=true;
      EP=Ask-SSpr+Offset;
//Alert(Symbol()," UnConf Up, Last Conf Dn: ",x," Conf Dn: ",y," UnConf Dn",n," Bar: ",i);
      Alert(Symbol()," UnConf Up, Go Long");
//      x=0; y=0; n=0;
//}//ttime

}//void

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void IfLo(){
//double x,y,z;
//x=0;y=0;z=0;
//for (int i=0;i<MaxBars;i++){
//   x=iCustom(Symbol(),tf,"FilteredZones",0,i);
//   y=iCustom(Symbol(),tf,"FilteredZones",1,i);
//   z=iCustom(Symbol(),tf,"FilteredZones",2,i);//UnConf Up
   //double n=iCustom(Symbol(),tf,"FilteredZones",3,i);//UnConf Dn
//   if(x>0 || y>0 || z>0){break;}
//}

//if(y>0){
      Short=true;
      EP=Bid+SSpr-Offset;
//Alert(Symbol()," UnConf Dn, Last Conf Up: ",x," Conf Dn: ",y," UnConf Up",z," Bar: ",i);
      Alert(Symbol()," UnConf Dn, Go Short");
//      x=0; y=0; z=0;
//}    

}//void

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void FindUnConfZone(){ //track left-side zones

if(iHigh(Symbol(),tf,0)==iHigh(Symbol(),tf,iHighest(Symbol(),tf,2,LZ,0))){
   HiZ2=iHigh(Symbol(),tf,0); //LoZ2=0;
   //Alert(Symbol(),"HiZ2: ",HiZ2);
}

if(iLow(Symbol(),tf,0)==iLow(Symbol(),tf,iLowest(Symbol(),tf,1,LZ,0))){
   LoZ2=iLow(Symbol(),tf,0); //HiZ2=0; 
   //Alert(Symbol(),"LoZ2: ",LoZ2);
}

}//void

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void FindUnConfZone2(){ //track left-side zones

if(iHigh(Symbol(),tf,0)==iHigh(Symbol(),tf,iHighest(Symbol(),tf,2,EZ,0))){
   HiZ2=iHigh(Symbol(),tf,0); //LoZ2=0;
   //Alert(Symbol(),"HiZ2: ",HiZ2);
}

if(iLow(Symbol(),tf,0)==iLow(Symbol(),tf,iLowest(Symbol(),tf,1,EZ,0))){
   LoZ2=iLow(Symbol(),tf,0); //HiZ2=0; 
   //Alert(Symbol(),"LoZ2: ",LoZ2);
}

}//void

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void Trader(){

if(HiZ2>0){
   Short=true; EP=Bid+SSpr-Offset;
   Alert(Symbol()," GoShort: ",EP-SSpr);
}
if(LoZ2>0){
   Long=true; EP=Ask-SSpr+Offset;
   Alert(Symbol()," GoLong: ",EP+SSpr);
}

}//void

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void Handler(){//Reward/Risk

if(Short){
   if(Bid<=EP-SSpr && EP>0){SMag=LZ*tf; EP=EP-SSpr; Alert(Symbol()," new EP: ",EP);}
}
if(Long){
   if(Ask>=EP+SSpr && EP>0){LMag=LZ*tf; EP=EP+SSpr; Alert(Symbol()," new EP: ",EP);}
}

}//void

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void DoGoLong(int Magix){
int result;
     
     result=OrderSend(Symbol(),OP_BUY,Lots,Ask,10,0,0,"BD "+DoubleToStr(Magix,0),Magix,0,Green);
     //Alert("result: ",result);
     if(result>0){LMag=0;}

}//void
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void DoGoShort(int Magix){
int result;
     
     result=OrderSend(Symbol(),OP_SELL,Lots,Bid,10,0,0,"BD "+DoubleToStr(Magix,0),Magix,0,Red);
     //Alert("result: ",result);
     if(result>0){SMag=0;}

}//void
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void Exit(){
   //Revs
  int y, s, total;  
  bool result;
    
    total = OrdersTotal();  
    s=0;

      for(y=0;y<total;y++) {
         OrderSelect(y,SELECT_BY_POS);
            if(OrderSymbol() == Symbol()){ 
                            if(Long && OrderType() == OP_BUY && OrderMagicNumber()==EMag) {
                                    result=OrderClose(OrderTicket(),OrderLots(),Bid,10,Green);
                                    if(result){
                                       Alert(Symbol()," SLTP: ",OrderProfit()," Mag: ",OrderMagicNumber());
                                       y--;
                                    }
                                    s++;
                                    Alert(Symbol()," Exit Long s: ",s);
                            }//OrderType()
                         
                            if(Short && OrderType() == OP_SELL && OrderMagicNumber()==EMag) {
                                    result=OrderClose(OrderTicket(),OrderLots(),Ask,10,Green);
                                    if(result){
                                       Alert(Symbol()," SLTP: ",OrderProfit()," Mag: ",OrderMagicNumber());
                                       y--;
                                    }
                                    s++;
                                    Alert(Symbol()," Exit Short s: ",s);
                            }//OrderType()
               }//Symbol
       }//for loop

                            if(Long && s==0){
                                       EMag=0;
                                       Long=false;
                                       s=0;
                                       Alert(Symbol()," Longs are dead");
                            }
                            if(Short && s==0){
                                       EMag=0;
                                       Short=false;
                                       s=0;
                                       Alert(Symbol()," Shorts are dead");
                            }

}//void
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void CheckStatus(){
  int y, total;
  EP=0;
            total = OrdersTotal();  
            for(y=0;y<total;y++) {
               OrderSelect(y,SELECT_BY_POS);
                 if(OrderSymbol() == Symbol() && OrderMagicNumber()==tf*LZ){ 
                     if(OrderType()==OP_SELL){
                     Short=true;
                     Alert(Symbol()," EP: ",OrderOpenPrice());
                       if(OrderOpenPrice()<=EP || EP==0){
                         EP=OrderOpenPrice();
                       }
                     }//buy
                     if(OrderType()==OP_BUY){
                     Long=true;
                     Alert(Symbol()," EP: ",OrderOpenPrice());
                       if(OrderOpenPrice()>=EP || EP==0){
                         EP=OrderOpenPrice();
                       }
                     }//buy                 
                 }//sym
              }//for
              if(Long){Alert("Long EP: ",EP);}
              if(Short){Alert("Short EP: ",EP);}
              
}//void
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void KillEverything(){
  int y, total;
  bool closed=false;
  bool ticket=false;
  
  Alert("Flatten");
  
            total = OrdersTotal();  
            for(y=0;y<total;y++) {
               OrderSelect(y,SELECT_BY_POS);
                 if(OrderSymbol() == Symbol() && OrderMagicNumber()==tf*LZ){ 
                     if(OrderType()==OP_BUY){
                              closed=OrderClose(OrderTicket(),OrderLots(),Bid,10,Gray);
                              if(!closed){
                                 //y--;
                              }
                     }
                    if(OrderType() == OP_BUYLIMIT || OrderType()==OP_BUYSTOP) {
                          ticket = OrderDelete(OrderTicket(),Gray);
                                if(ticket == true){
                                  //y--;//re-sets n to account for deleted order 
                                }//ticket
                     }
                     if(OrderType()==OP_SELL){
                              closed=OrderClose(OrderTicket(),OrderLots(),Ask,10,Gray);
                              if(!closed){
                                 //y--;
                              }
                     }
                    if(OrderType() == OP_SELLLIMIT || OrderType()==OP_SELLSTOP) {
                          ticket = OrderDelete(OrderTicket(),Gray);
                                if(ticket == true){
                                  //y--;//re-sets n to account for deleted order 
                                }//ticket
                     }
                 }
            }//for
}//void
