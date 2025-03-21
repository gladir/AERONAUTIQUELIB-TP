{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/CODER/AERONAUTIQUELIB-TP)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Unit ISA;

INTERFACE

Const
 SEA_LEVEL_PRESSURE=101325;    { Pression au niveau de la mer en Pascals }
 SEA_LEVEL_TEMPERATURE=288.15; { Temp‚rature au niveau de la mer en Kelvin }
 LAPSE_RATE=0.0065;            { Gradient thermique en K/m }
 GAS_CONSTANT=287.05;          { Constante des gaz en J/(kgúK) }
 GRAVITY=9.80665;              { Acc‚l‚ration gravitationnelle en m/sý }
 SOUND_SPEED_SEA_LEVEL=340.29; { Vitesse du son au niveau de la mer en m/s }

Type
  AltitudeBracket=(LowAltitude, MediumAltitude, HighAltitude);

Function BracketForAltitude(Altitude: Real):AltitudeBracket;
Function ClimbDistanceM(ClimbRate,ClimbTime:Real):Real;
Function ClimbTime(InitialAltitude,TargetAltitude,ClimbRate:Real):Real;
Function DescendTime(InitialAltitude,TargetAltitude,DescendRate:Real):Real;
Function gsForAltitude(Altitude:Real):Real;
Function PressureAtAltitude(Altitude:Real):Real;

IMPLEMENTATION

{ Cette fonction permet de calculer la puissance d'une base avec
 l'exposant sp‚cifi‚. }

Function Power(Base,Exponent:Real):Real;Begin
 Power:=Exp(Exponent*Ln(Base));
End;

{ Cette fonction permet de calculer la pression atmosph‚rique … une
  altitude donn‚e, en utilisant le modŠle standard jusqu'… 11 km et
  une formule sp‚cifique au-del….

  Altitude : altitude en mŠtres.

  Retourne la pression en Pascals … l'altitude donn‚e.
}

Function PressureAtAltitude(Altitude:Real):Real;Begin
 If Altitude < 11000 Then Begin { TroposphŠre, modŠle standard }
  PressureAtAltitude:=SEA_LEVEL_PRESSURE *
                      Power(1 - (LAPSE_RATE * Altitude) / SEA_LEVEL_TEMPERATURE,
                      (GRAVITY / (GAS_CONSTANT * LAPSE_RATE)));
 End
  Else
 Begin
  PressureAtAltitude:=22632.1 * Exp(-GRAVITY * (Altitude - 11000) / (GAS_CONSTANT * 216.65)); { StratosphŠre basse }
 End;
End;

{ Cette fonction permet de d‚terminer le groupe d'altitude auquel
  appartient une altitude donn‚e.

  Altitude : altitude en mŠtres.
  Retourne un type AltitudeBracket correspondant … la tranche d'altitude.
}

Function BracketForAltitude(Altitude:Real):AltitudeBracket;Begin
 If Altitude<11000 Then BracketForAltitude:=LowAltitude Else
 If Altitude < 20000 Then BracketForAltitude:=MediumAltitude
                     Else BracketForAltitude:=HighAltitude;
End;

{ Cette fonction permet de calculer la vitesse du son … une altitude
  donn‚e, en fonction de la temp‚rature de l'air … cette altitude.

  Altitude : altitude en mŠtres.
  Retourne la vitesse du son en m/s … l'altitude donn‚e.
}

Function gsForAltitude(Altitude:Real):Real;
Var
 TemperatureAtAltitude:Real;
Begin
 If Altitude < 11000 Then
   { TroposphŠre : temp‚rature diminue lin‚airement avec l'altitude }
  TemperatureAtAltitude:=SEA_LEVEL_TEMPERATURE - LAPSE_RATE * Altitude
 Else
   { StratosphŠre basse : temp‚rature constante au-del… de 11 km }
  TemperatureAtAltitude:=216.65;

 { Vitesse du son calcul‚e … partir de la temp‚rature, avec la formule :
  v = sqrt(gamma * R * T), o— T est la temp‚rature en Kelvin }
 gsForAltitude:=Sqrt(1.4*GAS_CONSTANT*TemperatureAtAltitude);
End;

{ Cette fonction permet de calculer le temps n‚cessaire pour atteindre
  une altitude cible en fonction de l'altitude de d‚part, de l'altitude
  cible et du taux de mont‚e (en m/s).

  InitialAltitude : altitude de d‚part en mŠtres.
  TargetAltitude : altitude cible en mŠtres.
  ClimbRate : taux de mont‚e en mŠtres par seconde.
  Retourne le temps de mont‚e en secondes.
}

Function ClimbTime(InitialAltitude,TargetAltitude,ClimbRate:Real):Real;
var
  TotalTime, CurrentAltitude: Real;
begin
  if ClimbRate <= 0 then Begin
   WriteLn('Le taux de mont‚e doit ˆtre sup‚rieur … z‚ro.');
   Exit;
 End;
 TotalTime:=0;
 CurrentAltitude:=InitialAltitude;
 While CurrentAltitude < TargetAltitude do Begin
   { Le temps pour chaque ‚tape est calcul‚ en fonction de la vitesse verticale.
     On suppose ici que la vitesse verticale est constante pendant la mont‚e. }
  TotalTime := TotalTime + 1 / ClimbRate; { Ajoute une seconde de temps pour chaque incr‚ment d'altitude }
  CurrentAltitude := CurrentAltitude + ClimbRate;
 End;
 ClimbTime:=TotalTime;
End;

{ Cette fonction permet de calculer la distance parcourue lors de la
  mont‚e en fonction du taux de mont‚e et du temps de mont‚e.

  ClimbRate : taux de mont‚e en m/s.
  ClimbTime : temps de mont‚e en secondes.
  Retourne la distance parcourue en mŠtres. }

Function ClimbDistanceM(ClimbRate,ClimbTime:Real):Real;Begin
 If ClimbRate <= 0 then Begin
   WriteLn('Le taux de mont‚e doit ˆtre sup‚rieur … z‚ro.');
   Exit;
  End;
  if ClimbTime <= 0 then Begin
   WriteLn('Le temps de mont‚e doit ˆtre sup‚rieur … z‚ro.');
   Exit;
  End;
  { La distance parcourue est simplement le produit du taux de mont‚e et du temps. }
 ClimbDistanceM:=ClimbRate*ClimbTime;
End;

{ Cette fonction permet de calculer le temps n‚cessaire pour
  redescendre d'une altitude donn‚e … une autre en fonction du taux
  de descente (en m/s).

  InitialAltitude : altitude de d‚part en mŠtres.
  TargetAltitude : altitude cible en mŠtres.
  DescendRate : taux de descente en mŠtres par seconde.
  Retourne le temps de descente en secondes.
}

Function DescendTime(InitialAltitude,TargetAltitude,DescendRate:Real):Real;
Var
 TotalTime:Real;
Begin
 If DescendRate<=0 then Begin
  WriteLn('Le taux de descente doit ˆtre sup‚rieur … z‚ro.');
  Exit;
 End;
 If InitialAltitude<=TargetAltitude Then Begin
  WriteLn('L''altitude de d‚part doit ˆtre sup‚rieure … l''altitude cible.');
  Exit;
 End;
 TotalTime:=(InitialAltitude-TargetAltitude)/DescendRate;
 descendTime:=TotalTime;
End;

END.