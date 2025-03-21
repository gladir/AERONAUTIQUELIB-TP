{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/CODER/AERONAUTIQUELIB-TP)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Unit CAS;

INTERFACE

Const
 SEA_LEVEL_PRESSURE=101325;    { Pression standard au niveau de la mer en Pascals }
 SEA_LEVEL_DENSITY=1.225;      { Densit‚ de l'air au niveau de la mer en kg/m3 }
 SEA_LEVEL_TEMPERATURE=288.15; { Temp‚rature standard au niveau de la mer en Kelvin }
 LAPSE_RATE=0.0065;            { Gradient thermique standard en K/m }
 GAS_CONSTANT=287.05;          { Constante des gaz en J/(kgúK) }
 GRAVITY=9.80665;              { Acc‚l‚ration gravitationnelle en m/sý }

Function PressureAtAltitude(Altitude:Real):Real;
Function DensityAtAltitude(Altitude:Real):Real;
Function TAS_to_CAS(TAS,Altitude:Real):Real;
Function CAS_to_TAS(CAS,Altitude:Real):Real;

IMPLEMENTATION

{ Cette fonction permet de calculer la puissance d'une base avec
 l'exposant sp‚cifi‚. }

Function Power(Base,Exponent:Real):Real;Begin
 Power:=Exp(Exponent*Ln(Base));
End;

{ Cette fonction permet de calculer la pression atmosph‚rique
  en fonction de l'altitude }

Function PressureAtAltitude(Altitude:Real):Real;Begin
 If Altitude<11000 Then Begin
  PressureAtAltitude:=SEA_LEVEL_PRESSURE*Power(1-(LAPSE_RATE*Altitude) /
                      SEA_LEVEL_TEMPERATURE,
                      (GRAVITY / (GAS_CONSTANT*LAPSE_RATE)))
 End
  Else
 Begin
  PressureAtAltitude:=22632.1*Exp(-GRAVITY*(Altitude-11000)/(GAS_CONSTANT*216.65));
 End;
End;

{ Cette fonction permet de calculer la densit‚ de l'air
  en fonction de l'altitude }

Function DensityAtAltitude(Altitude:Real):Real;
Var
 Pressure,Temperature:Real;
Begin
 Pressure:=PressureAtAltitude(Altitude);
 If Altitude<11000 Then
  Temperature:=SEA_LEVEL_TEMPERATURE-LAPSE_RATE*Altitude
 Else
  Temperature:=216.65;
 DensityAtAltitude:=Pressure/(GAS_CONSTANT*Temperature);
End;

 { Cette fonction permet de convertir la vitesse propre (TAS) en
   vitesse an‚mom‚trique corrig‚e (CAS) }

Function TAS_to_CAS(TAS,Altitude:Real):Real;
Var
 SeaLevelDensity,Density:Real;
Begin
 SeaLevelDensity:=SEA_LEVEL_DENSITY;
 Density:=DensityAtAltitude(Altitude);
 TAS_to_CAS:=TAS*Sqrt(Density/SeaLevelDensity);
End;

 { Cette fonction permet de convertir la vitesse an‚mom‚trique
  corrig‚e (CAS) en vitesse propre (TAS) }

Function CAS_to_TAS(CAS,Altitude:Real):Real;
Var
 SeaLevelDensity,Density:Real;
Begin
 SeaLevelDensity := SEA_LEVEL_DENSITY;
 Density := DensityAtAltitude(Altitude);
 CAS_to_TAS := CAS / Sqrt(Density / SeaLevelDensity);
End;

END.
