/* Portable photo trigger


created 2011
by Lorenzo Boasso
*/


// pin digitali
int wakePin = 0;
int shotPin = 1;
int ledActivePin = 2;

// pin analogici
int lightPin = 3;
int configPin = 2;

// valori opzionali - più valori si mettono è più sensibile sarà la precisione della selezione
#define LENARRAY 12 // attenzione, questo valore deve corrispondere al numero di elementi dell'array
int confArray[LENARRAY] = {4,30,80,5, 8,15,30,60,180,600,1800,3600};

int ledBlinkWait = 1000; 
int ledState = LOW;

int lightSet = 0;

long prevBlinkMillis = 0;        // will store last time LED was updated
long prevShotMillis = 0;        // will store last time LED was updated

int prevLight = 0;

int selection = 0;
int wakeInteval = 500; // quanti millisecondi prima dello scatto viene premuti il wake

unsigned long currentMillis = 0;

void setup() {
  
  // CONFIGURAZIONE PIN
  // scatto
  pinMode(wakePin, OUTPUT);
  pinMode(shotPin, OUTPUT); 
  // led
  pinMode(ledActivePin, OUTPUT);
  
  // spengo tutto
  digitalWrite(wakePin, LOW);
  digitalWrite(shotPin, LOW); 
  
  // trigger attivo
  digitalWrite(ledActivePin, HIGH);
  
  currentMillis = millis();
  prevShotMillis = millis();
  prevBlinkMillis = millis();
}

void loop() 
{ 
  selection = analogRead(configPin);            // reads the value of the potentiometer (value between 0 and 1023) 
  selection = map(selection,0, 1023, 1, LENARRAY) ;

  currentMillis = millis();

  if (selection <5){ // i primi 4 valori si riferiscono al trigger lumninoso
  
    // modalita fotoresistenza
    digitalWrite(ledActivePin, HIGH);
  
    int lightVal = analogRead(lightPin);
    if ((prevLight - lightVal > confArray[selection]) ||(lightVal - prevLight  > confArray[selection]) ){
      wakeUp();
      delay(100); 
      shot();
      delay(200);
    }
  
    prevLight = analogRead(lightPin);
    
  }else{
    // modalità intervallometro
    blinkLed();
    
    if((currentMillis - prevShotMillis) > ((confArray[selection]*1000)-wakeInteval)) {
       wakeUp();
    }
    
    if((currentMillis - prevShotMillis) > (confArray[selection]*1000)) {
       shot();
    }

  }
  
} 

void wakeUp(){
    digitalWrite(wakePin, HIGH); //turn wakeup/focus on
}

void shot(){
     // save the last time you blinked the LED 
    prevShotMillis = currentMillis;   

    digitalWrite(shotPin, HIGH); //turn wakeup/focus on
    delay(100); //faccio durare qualche istante la pressione del tasto
    
    // rilascrio tutto
    digitalWrite(shotPin, LOW); //turn wakeup/focus on
    digitalWrite(wakePin, LOW); //turn wakeup/focus on
}

void blinkLed(){
  // if the LED is off turn it on and vice-versa:
    unsigned long currentMillis = millis();
    if(currentMillis - prevBlinkMillis > ledBlinkWait) {
      prevBlinkMillis = currentMillis;
      if (ledState == LOW)
        ledState = HIGH;
      else
        ledState = LOW;
        
      // set the LED with the ledState of the variable:
      digitalWrite(ledActivePin, ledState);
    }
}


