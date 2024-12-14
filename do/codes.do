********Limpieza de la base de datos***********

***************************
********¡Importante!*******
***************************
/*Antes de ejecturar el do-file, cargar en el directorio de trabajo de su computadora las bases de datos "BASE DE TRABAJO DE HOGARES.dta", "BASE DE TRABAJO DE PERSONAS.dta" y "ECV6R_PERSONAS.dta". Estas bases han sido incuidas en el envío a la carpeta del D2L. Para cambiar el directorio de trabajo (donde va a guardar las mencionadas bases) puede usar el comando cd.*/


//Comencemos por cargar la base "ECV6R_PERSONAS.dta" en el editor de datos y quedarnos solamente con las variables que son de interés:
clear all
use "ECV6R_PERSONAS",clear
keep REGION FEXP PA25A PA25B PA30B PA33A2 PA33B2 PA33C2 PA37 PA38B PA39A PA39B PA40B PA42B PA43B PA44B PA45B PA45C PA46A PA46B PA62 PA65A PA65B PA66 PA67B PA68A PA69B PA71B PA80A PA80B PA80C PA81B PA81C PA85B PA85C PA88 PA43C PA45B PA63A PA63B PD04 IDENTIF_HOG PB05L PD07 PB05D PB07A PB07B PA23A PA23B PB05A PB05B PB05C PB05E PB05F PB05G PB05H PB05I PB05J PB05K PB05M PB05N PB05O PB05P PB05Q PB05R PB05S PB05T PA22 PA81A
drop if PD04 !=1 //Nos quedamos solamente con las observaciones del jefe de hogar.
drop PD04 //Esta variable es irrelevante para nuestros propósitos, ya que solamente nos es útil para la anterior línea de código.
save "ECV6R_PERSONAS_modificado" 

//Abramos la base "BASE DE TRABAJO DE PERSONAS.dta" y mantengamos las variables de interés:
use "BASE DE TRABAJO DE PERSONAS",clear
keep PID002 PAE001 PDE000
drop if PDE000 !=1 //Solo jefes de hogar.
drop PDE000
rename PID002 IDENTIF_HOG //Cambiar nombre de variable de identificador de hogar para tener una variable en común en ambas bases. Esto nos permitirá después usar el comando merge.
save"BASE DE TRABAJO DE PERSONAS_modificado" 

//Abramos la base "BASE DE TRABAJO DE HOGARES.dta" en el editor de datos y consideremos las variables relevantes:
use "BASE DE TRABAJO DE HOGARES", clear
rename HID002 IDENTIF_HOG //Cambiar nombre de variable de identificador de hogar para tener una variable en común en ambas bases. Esto nos permitirá después usar el comando merge.
keep IDENTIF_HOG HJH006 HVI025 HJH001 HJH002 HJH005 

//Usemos merge para unir las bases de datos modificadas. Para que exista una correspondencia entre los datos usaremos el identificador del hogar.
merge 1:1 IDENTIF_HOG using "ECV6R_PERSONAS_modificado" //Hagamos el merge entre "ECV6R_PERSONAS_modificado" y "BASE DE TRABAJO DE HOGARES".
drop _merge
merge 1:1 IDENTIF_HOG using "BASE DE TRABAJO DE PERSONAS_modificado" //Terminando de unir las bases.
drop _merge IDENTIF_HOG

********Cálculo del ingreso***********
//Vamos a reemplazar por ceros los missing values o las variables para las cuales el individuo no informa.
foreach v of varlist  PA25A PA25B PA30B PA33A2 PA33B2 PA33C2 PA37 PA38B PA39B PA40B PA42B PA43B PA45B PA45C PA46A PA44B PA46B PA65A PA65B PA66 PA67B PA68A PA69B PA71B PA80A PA80B PA80C PA81B PA81C PA88 PA85B PA85C PA44B PA43B PA43C PA45B PA45C PA46A PA46B PA71B PA23A PA23B PA63A PA63B PA81A{   
	replace `v'=0 if (`v'== .|`v'== -1) 
}

********Ingreso laboral**********
//Primer trabajo
rename PA44B monto_vivienda_mes_1 

gen pago_alimentos_1 = PA43B * 30 if PA43C==1
replace pago_alimentos_1 = PA43B * 4.29 if PA43C==2
replace pago_alimentos_1 = PA43B * 2 if PA43C==3
replace pago_alimentos_1 = PA43B * 1 if PA43C==4

gen ropa_trabajo_1 = (PA45B * PA45C) / 12

gen pago_transporte_1 = PA46B * 1 if (PA46A==1|PA46A==2)

rename PA71B monto_alimentos_uniformes_etc

gen pago_trabajo_1 = PA23A *30 if PA23B==1
replace pago_trabajo_1 = PA23A *4.29 if PA23B==2
replace pago_trabajo_1 = PA23A *2 if PA23B==3
replace pago_trabajo_1 = PA23A *1 if PA23B==4
replace pago_trabajo_1 = (PA23A /3) if PA23B==5
replace pago_trabajo_1 = (PA23A /6) if PA23B==6
replace pago_trabajo_1 = (PA23A /12) if PA23B==7

gen salario_o_jornal_1 = PA25A * 30 if PA25B == 1
replace salario_o_jornal_1 = PA25A * 4.29 if PA25B == 2
replace salario_o_jornal_1 = PA25A * 2 if PA25B == 3
replace salario_o_jornal_1 = PA25A * 1 if PA25B == 4

rename PA45B monto_ropa_trabajo

gen aniversario = (PA30B / 12)
gen bono_vacacional = (PA33A2 / 12)
gen aguinaldo = (PA33B2 / 12)
gen utilidades = (PA33C2 / 12)
gen decimo_tercer_sueldo_1 = (PA38B / 12)

gen decimo_cuarto_1 = (340 / 12) if (PA39A == 1 & (PA22 == 1 | PA22 == 2 | PA22 == 9 | PA22 == 10 | PA22 == 17) )

rename PA40B monto_horas_extras_1  
rename PA42B  monto_comisiones_propinas

foreach v of varlist monto_vivienda_mes_1 pago_alimentos_1 ropa_trabajo_1 pago_transporte_1 monto_alimentos_uniformes_etc pago_trabajo_1 salario_o_jornal_1 monto_ropa_trabajo aniversario bono_vacacional aguinaldo utilidades decimo_tercer_sueldo_1 decimo_cuarto_1 monto_horas_extras_1 monto_comisiones_propinas {   
	replace `v'=0 if (`v'== .)
}

gen pagos_extraordinarios = bono_vacacional + aguinaldo + utilidades + decimo_tercer_sueldo_1 + decimo_cuarto_1 + monto_horas_extras + monto_comisiones_propinas + pago_transporte_1 + aniversario

//Ingreso segundo trabajo
gen salario_o_jornal_2 = PA65A * 30 if PA65B == 1
replace salario_o_jornal_2 = PA65A * 4.29 if PA65B == 2
replace salario_o_jornal_2 = PA65A * 2 if PA65B == 3
replace salario_o_jornal_2 = PA65A * 1 if PA65B == 4

rename PA66 salario_total_2

gen decimo_tercer_sueldo_2 = (PA67B/12)

gen pago_trabajo_2 = PA63A *30 if PA63B==1
replace pago_trabajo_2 = PA63A *4.29 if PA63B==2
replace pago_trabajo_2 = PA63A *2 if PA63B==3
replace pago_trabajo_2 = PA63A *1 if PA63B==4
replace pago_trabajo_2 = (PA63A /3) if PA63B==5
replace pago_trabajo_2 = (PA63A /6) if PA63B==6
replace pago_trabajo_2 = (PA63A /12) if PA63B==7

gen decimo_cuarto_2 = (340/ 12) if (((PA68A==1) & ( PA62 == 1 | PA62 == 2 | PA62 == 9 | PA62 == 10 | PA62 == 17)))

rename PA69B monto_horas_extras_2

foreach v of varlist salario_o_jornal_2 salario_total_2 decimo_tercer_sueldo_2 pago_trabajo_2  decimo_cuarto_2 monto_horas_extras_2  {   
	replace `v'=0 if (`v'== .)
}


//Ingreso laboral total
gen suma_decimos_horasExtras = decimo_tercer_sueldo_2 + decimo_cuarto_2 + monto_horas_extras_2
gen suma_salar1_montRop_pagosExtr = salario_o_jornal_1 + monto_ropa_trabajo + pagos_extraordinarios
gen suma_salar2_salarTo2_sumaDecim = salario_o_jornal_2 + salario_total_2 + suma_decimos_horasExtras

gen suma_ingresos_laboral_total= suma_salar1_montRop_pagosExtr + suma_salar2_salarTo2_sumaDecim


********Ingreso de remesas y BDH**********
gen dinero_amigos_familiares_pais = PA80B * 30 if (PA80A == 1 & PA80C == 1)
replace dinero_amigos_familiares_pais = PA80B * 4.29 if (PA80A == 1 & PA80C == 2)
replace dinero_amigos_familiares_pais = PA80B * 2 if (PA80A == 1 & PA80C == 3)
replace dinero_amigos_familiares_pais = PA80B * 1 if (PA80A == 1 & PA80C == 4)
replace dinero_amigos_familiares_pais = PA80B / 3 if (PA80A == 1 & PA80C == 5)
replace dinero_amigos_familiares_pais = PA80B / 6 if (PA80A == 1 & PA80C == 6)
replace dinero_amigos_familiares_pais = PA80B / 12 if (PA80A == 1 & PA80C == 7)

gen dinero_amigos_familiares_extran = PA81B * 30 if (PA81A == 1 & PA81C == 1)
replace dinero_amigos_familiares_extran = PA81B * 4.29 if (PA81A == 1 & PA81C == 2)
replace dinero_amigos_familiares_extran = PA81B * 2 if (PA81A == 1 & PA81C == 3)
replace dinero_amigos_familiares_extran = PA81B * 1 if (PA81A == 1 & PA81C == 4)
replace dinero_amigos_familiares_extran = PA81B / 3 if (PA81A == 1 & PA81C == 5)
replace dinero_amigos_familiares_extran = PA81B / 6 if (PA81A == 1 & PA81C == 6)
replace dinero_amigos_familiares_extran = PA81B / 12 if (PA81A == 1 & PA81C == 7)

//calculo del bono de DH
gen bono_DH = 50 if (PA88 == 1)

gen ayudas_dinero = PA85B * 30 if (PA85C == 1)
replace ayudas_dinero = PA85B * 4.29 if (PA85C == 2)
replace ayudas_dinero = PA85B * 2 if (PA85C == 3)
replace ayudas_dinero = PA85B * 1 if (PA85C == 4)
replace ayudas_dinero = PA85B /3 if (PA85C == 5)
replace ayudas_dinero = PA85B /6 if (PA85C == 6)
replace ayudas_dinero = PA85B /12 if (PA85C == 7)


foreach v of varlist dinero_amigos_familiares_pais dinero_amigos_familiares_extran bono_DH ayudas_dinero  {   
	replace `v'=0 if (`v'== .)
}

gen suma_ingresos_no_laborales_total = dinero_amigos_familiares_pais + dinero_amigos_familiares_extran + bono_DH + ayudas_dinero

gen ingreso = suma_ingresos_laboral_total + suma_ingresos_no_laborales_total

drop PA33A2 PA33B2 PA33C2 PA37 PA38B PA39A PA39B monto_horas_extras_1 monto_comisiones_propinas PA43B PA43C monto_vivienda_mes_1 monto_ropa_trabajo PA45C PA46A PA46B PA62 PA63A PA63B PA65A PA65B salario_total_2 PA67B PA68A monto_horas_extras_2 monto_alimentos_uniformes_etc PA80A PA80B PA80C PA81A PA81B PA81C PA85B PA85C PA88 PA22 PA23A PA23B PA25A PA25B PA30B pago_alimentos_1 ropa_trabajo_1 pago_transporte_1 pago_trabajo_1 salario_o_jornal_1 aniversario bono_vacacional aguinaldo utilidades decimo_tercer_sueldo_1 decimo_cuarto_1 pagos_extraordinarios salario_o_jornal_2 decimo_tercer_sueldo_2 pago_trabajo_2 decimo_cuarto_2 suma_decimos_horasExtras suma_salar1_montRop_pagosExtr suma_salar2_salarTo2_sumaDecim suma_ingresos_laboral_total dinero_amigos_familiares_pais dinero_amigos_familiares_extran bono_DH ayudas_dinero suma_ingresos_no_laborales pago_trabajo_2 monto_vivienda_mes_1 pago_alimentos_1 ropa_trabajo_1  monto_alimentos_uniformes_etc pago_trabajo_1

********Transformación de otras variables***********

//Eliminemos todas las observaciones con missing values para las cuales el participante no informa :
foreach v of var * { 
	drop if missing(`v') |`v'==-1
}

//Agreguemos un label a la variable de ingreso
label variable ingreso "Ingreso mensual incluido remesas, bonos, etc."


//Indice bienestar
gen indice=PB05A + PB05B + PB05C + (7-PB05D) + PB05E + PB05F + PB05G + (7-PB05H) + PB05I + PB05J + PB05K  +(7-PB05L)+  PB05M +  PB05N + PB05O +  (7-PB05P) + PB05Q + PB05R +PB05S + PB05T
replace indice=indice/(140/100) 
//Notar que las variables que representan algo positivo (como los días que la persona está contenta) se calculan como 7-variable. Por otro lado, las variables "negativas" (como días que se sintió triste) las sumamos. Luego, dividimos para el máximo valor posible de esta suma (7*20=140) entre cien. El resultado es un índice que entre más cercano a cien esté, menor es el bienestar de la persona.
replace indice=100-indice //Hacemos esto para tener un índice que entre más cercano a cien se encuentre, la persona tiene más bienestar.
label variable indice "Indice de bienestar 0-100 (entre más alto, más bienestar tiene la persona)"

//Cambio nombre variables
rename HVI025 vivienda_propia
rename HJH001 hombre
rename HJH002 edad
rename HJH005 casado
rename HJH006 educ
rename PD07 discapacidad
rename PB07A importancia_familia
rename PB07B importancia_popularidad
rename ingreso ingreso_absoluto
rename PAE001 actividad
rename FEXP factor_expansion 
gen edad_cuadrado = edad^2
keep vivienda_propia hombre edad edad_cuadrado casado educ REGION discapacidad importancia_familia importancia_popularidad ingreso_absoluto indice actividad factor_expansion

label variable actividad "Variable categórica rama actividad"
label variable REGION "Variable categórica región jefe hogar"
label variable edad_cuadrado "Edad elevada al cuadrado"

//Transformar variables a dummys
label drop HVI025 //Eliminar etiqueta
replace vivienda_propia=0 if vivienda_propia !=2 
replace vivienda_propia=1 if vivienda_propia ==2 
label variable vivienda_propia "1 tiene vivienda propia, 0 lo contrario"


label drop HJH001 //Eliminar etiqueta
replace hombre =0 if hombre ==2 
label variable hombre "1 igual a hombre, 0 mujer"

label drop HJH002 //Eliminar etiqueta

label drop HJH005 //Eliminar etiqueta
replace casado =0 if casado !=1 
label variable casado "1 igual a casado, 0 caso contrario"

label drop HJH006 //Eliminar etiqueta
//Tomará el valor 0 si la persona no tuvo educación o solamente primaria:
replace educ=0 if educ==1 | educ==2 
//Tomará el valor 1 si la persona aprobó la secundaria o estudios superiores:
replace educ=1 if educ==3 | educ==4
label variable educ "1 si aprobó la secundaria, 0 caso contrario"

label drop labels13 //Eliminar etiqueta
replace discapacidad =0 if discapacidad ==2
label variable discapacidad "1 si tiene discapacidad, 0 caso contrario"

label drop labels620 //Eliminar etiqueta
replace importancia_familia=1 if importancia_familia < 3 //1 si contestó que la familia era muy importante o importante.
replace importancia_familia =0 if importancia_familia >= 3 
label variable importancia_familia "1 si es importante la familia, 0 si no es importante"


label drop labels621 //Eliminar etiqueta
replace importancia_popularidad=1 if importancia_popularidad < 3 //1 si contestó que la popularidad era muy importante o importante.
replace importancia_popularidad =0 if importancia_popularidad >=3
label variable importancia_popularidad "1 si es importante la popularidad, 0 si no es importante"

//Cambiar orden variables
order indice vivienda_propia hombre edad edad_cuadrado casado educ discapacidad ingreso_absoluto importancia_familia importancia_popularidad actividad REGION factor_expansion

//Guardar base:
save "Base de datos final"

//Tener tabla con variables y etiquetas:
ssc install descsave //Instalar paquete
descsave, saving(descripcion_vars.dta, replace) //Guardar en tabla en formato dta.
use descripcion_vars
export excel using "descripcion_vars", firstrow(variables)


********Estadísticas resumen***********
clear all
use "Base de datos final"

//Instalar paquetes:
ssc install asdoc
ssc install estout
net install http://www.stata.com/users/kcrow/tab2xl, replace

//Estadísticas resumen de variables continuas y binarias
sum indice vivienda_propia hombre edad casado educ discapacidad ingreso_absoluto importancia_familia importancia_popularidad [aw=factor_expansion]  //tabla de estadísticos resumen

outreg2 using summary_stat.xls [aw=factor_expansion], replace sum(log) keep(indice vivienda_propia hombre edad casado educ discapacidad ingreso_absoluto importancia_familia importancia_popularidad) //exportamos nuestros estadísticos resumen para las variables binarias y continuas

//Tabulación actividad
tab actividad //Tabulación de actividad
tab2xl actividad[aw=factor_expansion] using tab_actividad, col(1) row(1)

//Histograma ingreso:
hist ingreso_abs [w=round(factor_expansion)]



********Regresiones***********
clear all
use "Base de datos final"

//Estimación de modelo (1)
tobit ingreso_absoluto edad edad_cuadrado educ hombre i.REGION i.actividad [pw=factor_expansion], ll(0)
outreg2 using tobit.xls
predict ingreso_rel, e(0,.) //Estimación del ingreso relativo.
label variable ingreso_rel "Ingreso relativo"

// Vamos a generar variables con logaritmos para ingreso_abs e ingreso_rel
gen ln_ingreso_abs=ln(ingreso_absoluto)
label variable ln_ingreso_abs "Logaritmo ingreso absoluto"

gen ln_ingreso_rel=ln(ingreso_rel)
label variable ln_ingreso_rel "Logaritmo ingreso relativo"

//Estimación del modelo (2)
reg indice ln_ingreso_abs vivienda_propia edad edad_cuadrado hombre casado educ discapacidad importancia_familia importancia_popularidad [pw=factor_expansion], rob
outreg2 using regresiones.xls, replace ctitle(No ln_ingreso_rel,.)

reg indice ln_ingreso_abs ln_ingreso_rel vivienda_propia edad edad_cuadrado hombre casado educ discapacidad importancia_familia importancia_popularidad [pw=factor_expansion], rob
outreg2 using regresiones.xls, append ctitle(ln_ingreso_rel,.)

save "Base de datos final.dta", replace