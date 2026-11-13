// -----------------------------------------------------------------
// BASE DE DATOS DE RELIQUIAS Y DESCRIPCIONES CORTAS
// -----------------------------------------------------------------
SubProceso ObtenerDetallesReliquia(id Por Valor, nombre Por Referencia, descripcion Por Referencia)
	Segun id Hacer
		1: 
			nombre <- "Anillo de Defensa";
			descripcion <- "+25 Vida Maxima y cura +25 HP";
		2: 
			nombre <- "Anillo Critico";
			descripcion <- "25% probabilidad de golpe critico (x2)";
		3: 
			nombre <- "Collar de Espinas";
			descripcion <- "Devuelve 10 de dano al atacante";
		4: 
			nombre <- "Monedero";
			descripcion <- "+15 monedas extra al superar salas";
		5: 
			nombre <- "Mazo de Obsidiana";
			descripcion <- "+12 de dano fisico permanente";
		6: 
			nombre <- "Excalibur";
			descripcion <- "+10 de dano fisico legendario";
		7: 
			nombre <- "Daga Venenosa";
			descripcion <- "+6 de dano venenoso por impacto";
		8: 
			nombre <- "Bomba de Humo";
			descripcion <- "20% probabilidad de esquivar ataques";
		9: 
			nombre <- "Daga Vampirica";
			descripcion <- "Cura el 20% del dano infligido";
		10: 
			nombre <- "Libro Volcanico";
			descripcion <- "8 de dano de fuego en area por turno";
		De Otro Modo:
			nombre <- "Vacio";
			descripcion <- "Sin objeto equipado";
	FinSegun
FinSubProceso

// -----------------------------------------------------------------
// PISTAS AMBIENTALES PARA LAS SALAS DEL MAPA
// -----------------------------------------------------------------
SubProceso ObtenerPistaSala(tipoSala Por Valor, pista Por Referencia)
	Segun tipoSala Hacer
		1: pista <- "Se escuchan grunidos y un fuerte olor a muerto...";
		2: pista <- "Pasos arrastrados y el crujir de huesos viejos...";
		3: pista <- "Un burbujeo viscoso seguido del choque de huesos...";
		4: pista <- "Tienes un mal presentimiento... no creo que sea buena idea.";
		5: pista <- "El suelo vibra con un chapoteo gelatinoso y acido...";
		De Otro Modo:
			pista <- "Un pasillo oscuro y silencioso...";
	FinSegun
FinSubProceso

// -----------------------------------------------------------------
// FUNCION AUXILIAR: Verifica si el jugador tiene una reliquia equipada
// -----------------------------------------------------------------
Funcion posee <- TieneReliquia(inventarioReliquias Por Referencia, nombreBuscado Por Valor)
	Definir posee Como Logico;
	Definir i Como Entero;
	posee <- Falso;
	Para i <- 1 Hasta 5 Hacer
		Si inventarioReliquias(i) == nombreBuscado Entonces
			posee <- Verdadero;
		FinSi
	FinPara
FinFuncion

// -----------------------------------------------------------------
// ORQUESTADOR DE RELIQUIAS (Controlador central de efectos pasivos)
// Fases soportadas: "INICIO_TURNO", "AL_ATACAR", "AL_RECIBIR_DANO", "FIN_SALA"
// -----------------------------------------------------------------
SubProceso OrquestadorReliquias(fase Por Valor, inventarioReliquias Por Referencia, vidaActual Por Referencia, vidaMaxima Por Valor, danoBase Por Valor, danoFinal Por Referencia, danoEntrante Por Referencia, danoReflejado Por Referencia, danoAreaTurno Por Referencia, oro Por Referencia)
	Definir curacionVampirica Como Entero;
	
	// Reiniciar variables de salida de este evento
	danoFinal <- danoBase;
	danoReflejado <- 0;
	danoAreaTurno <- 0;
	
	// -------------------------------------------------------------
	// FASE 1: INICIO DEL TURNO (Efectos pasivos de area)
	// -------------------------------------------------------------
	Si fase == "INICIO_TURNO" Entonces
		// [ID 10] Libro Volcanico: Quema a todos los enemigos vivos por 8 de dano
		Si TieneReliquia(inventarioReliquias, "Libro Volcanico") Entonces
			danoAreaTurno <- 8;
			Escribir "[Reliquia: Libro Volcanico] Las llamas queman a todos los enemigos (-8 HP).";
		FinSi
	FinSi
	
	// -------------------------------------------------------------
	// FASE 2: AL ATACAR (Criticos, Veneno y Robo de Vida)
	// -------------------------------------------------------------
	Si fase == "AL_ATACAR" Entonces
		// [ID 2] Anillo Critico: 25% de probabilidad de golpe critico (x2 dano)
		Si TieneReliquia(inventarioReliquias, "Anillo Critico") Entonces
			Si Aleatorio(1, 100) <= 25 Entonces
				danoFinal <- danoFinal * 2;
				Escribir "[Reliquia: Anillo Critico] ¡GOLPE CRITICO! Dano duplicado a ", danoFinal, ".";
			FinSi
		FinSi
		
		// [ID 7] Daga Venenosa: Anade +6 de dano venenoso por impacto
		Si TieneReliquia(inventarioReliquias, "Daga Venenosa") Entonces
			danoFinal <- danoFinal + 6;
			Escribir "[Reliquia: Daga Venenosa] Veneno aplicado (+6 de dano extra).";
		FinSi
		
		// [ID 9] Daga Vampirica: Recupera el 20% del dano infligido (minimo 1 HP)
		Si TieneReliquia(inventarioReliquias, "Daga Vampirica") Entonces
			curacionVampirica <- trunc(danoFinal * 0.20);
			Si curacionVampirica < 1 Entonces
				curacionVampirica <- 1;
			FinSi
			Si vidaActual < vidaMaxima Entonces
				vidaActual <- vidaActual + curacionVampirica;
				Si vidaActual > vidaMaxima Entonces
					vidaActual <- vidaMaxima;
				FinSi
				Escribir "[Reliquia: Daga Vampirica] Absorbes ", curacionVampirica, " HP del enemigo.";
			FinSi
		FinSi
	FinSi
	
	// -------------------------------------------------------------
	// FASE 3: AL RECIBIR DANO (Evasion y Espinas)
	// -------------------------------------------------------------
	Si fase == "AL_RECIBIR_DANO" Entonces
		// [ID 8] Bomba de Humo: 20% de probabilidad de evadir el ataque
		Si TieneReliquia(inventarioReliquias, "Bomba de Humo") Entonces
			Si Aleatorio(1, 100) <= 20 Entonces
				danoEntrante <- 0;
				Escribir "[Reliquia: Bomba de Humo] ¡Desapareces en el humo y esquivas el ataque!";
			FinSi
		FinSi
		
		// [ID 3] Collar de Espinas: Devuelve 10 de dano al atacante (incluso si esquivas)
		Si TieneReliquia(inventarioReliquias, "Collar de Espinas") Entonces
			danoReflejado <- 10;
			Escribir "[Reliquia: Collar de Espinas] Las espinas devuelven 10 de dano al atacante.";
		FinSi
	FinSi
	
	// -------------------------------------------------------------
	// FASE 4: FIN DE SALA (Bonificacion economica)
	// -------------------------------------------------------------
	Si fase == "FIN_SALA" Entonces
		// [ID 4] Monedero: Otorga +15 de oro adicional al completar un piso de combate
		Si TieneReliquia(inventarioReliquias, "Monedero") Entonces
			oro <- oro + 15;
			Escribir "[Reliquia: Monedero] ¡Encuentras 15 monedas de oro adicionales!";
		FinSi
	FinSi
FinSubProceso

// -----------------------------------------------------------------
// INTERFAZ DE INVENTARIO EN COMBATE (Con uso funcional de pociones)
// -----------------------------------------------------------------
SubProceso VerInventarioCombate(cantidadpociones Por Referencia, inventarioReliquias Por Referencia, totalReliquiasEquipadas Por Valor, vidaActual Por Referencia, vidaMaxima Por Valor, danojugador Por Valor, oro Por Valor)
	Definir opcionInv Como Caracter;
	Definir i Como Entero;
	
	Repetir
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir "          INVENTARIO DEL JUGADOR         ";
		Escribir "=========================================";
		Escribir "Vida: ", vidaActual, " / ", vidaMaxima;
		Escribir "Dano base actual: ", danojugador;
		Escribir "Oro disponible: ", oro, " monedas";
		Escribir "Pociones disponibles: ", cantidadpociones;
		Escribir "-----------------------------------------";
		Escribir "SLOTS DE RELIQUIAS PASIVAS (", totalReliquiasEquipadas, " / 5):";
		
		Para i <- 1 Hasta 5 Hacer
			Si i <= totalReliquiasEquipadas Entonces
				Escribir "  [Slot ", i, "] -> ", inventarioReliquias(i);
			SiNo
				Escribir "  [Slot ", i, "] -> [ Vacio ]";
			FinSi
		FinPara
		
		Escribir "=========================================";
		Escribir " [1] Usar una Pocion (+50 HP)";
		Escribir " [2] Salir del Inventario (Volver al combate)";
		Escribir "=========================================";
		Escribir Sin Saltar "Elige una opcion: ";
		Leer opcionInv;
		
		Si opcionInv == "1" Entonces
			Si cantidadpociones > 0 Entonces
				Si vidaActual < vidaMaxima Entonces
					cantidadpociones <- cantidadpociones - 1;
					vidaActual <- vidaActual + 50;
					
					Si vidaActual > vidaMaxima Entonces
						vidaActual <- vidaMaxima;
					FinSi
					
					Escribir "¡Te has tomado una pocion! Recuperas salud.";
					Esperar 2.5 Segundos;
				SiNo
					Escribir "¡Tienes la vida a tope!";
					Esperar 2.5 Segundos;
				FinSi
			SiNo
				Escribir "¡No tienes pociones disponibles!";
				Esperar 2.5 Segundos;
			FinSi
		SiNo
			Si opcionInv <> "2" Entonces
				Escribir "Opcion invalida. Elige 1 o 2.";
				Esperar 2 Segundos;
			FinSi
		FinSi
	Hasta Que opcionInv == "2"
FinSubProceso

// -----------------------------------------------------------------
// SISTEMA DE COFRE POST-COMBATE (Con Descripciones Breves)
// -----------------------------------------------------------------
SubProceso AbrirCofrePostCombate(inventarioReliquias Por Referencia, totalReliquiasEquipadas Por Referencia, oro Por Referencia, danojugador Por Referencia, vidaActual Por Referencia, vidaMaxima Por Referencia)
	Definir id1, id2 Como Entero;
	Definir nombre1, descripcion1, nombre2, descripcion2 Como Caracter;
	Definir opcionCofre Como Caracter;
	Definir reliquiaElegida, reliquiaDescartada Como Caracter;
	Definir esRepetida Como Logico;
	Definir i Como Entero;
	Definir opcionReemplazo Como Caracter;
	Definir slotAElegir Como Entero;
	
	// Sortear Reliquia 1 asegurando que NO la tenga equipada
	Repetir
		id1 <- Aleatorio(1, 10);
		ObtenerDetallesReliquia(id1, nombre1, descripcion1);
		esRepetida <- Falso;
		Para i <- 1 Hasta totalReliquiasEquipadas Hacer
			Si inventarioReliquias(i) == nombre1 Entonces
				esRepetida <- Verdadero;
			FinSi
		FinPara
	Hasta Que esRepetida == Falso
	
	// Sortear Reliquia 2 asegurando que NO la tenga y que sea distinta a la 1
	Repetir
		id2 <- Aleatorio(1, 10);
		ObtenerDetallesReliquia(id2, nombre2, descripcion2);
		esRepetida <- Falso;
		Si id2 == id1 Entonces
			esRepetida <- Verdadero;
		SiNo
			Para i <- 1 Hasta totalReliquiasEquipadas Hacer
				Si inventarioReliquias(i) == nombre2 Entonces
					esRepetida <- Verdadero;
				FinSi
			FinPara
		FinSi
	Hasta Que esRepetida == Falso
	
	// Menu principal del cofre con descripciones breves
	Repetir
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir "            ¡SALA SUPERADA!             ";
		Escribir "           ¡ABRISTE UN COFRE!           ";
		Escribir "=========================================";
		Escribir " Elige una reliquia para tu inventario:  ";
		Escribir " ";
		Escribir " [1] ", nombre1;
		Escribir "     - ", descripcion1;
		Escribir " ";
		Escribir " [2] ", nombre2;
		Escribir "     - ", descripcion2;
		Escribir " ";
		Escribir " [3] Rechazar ambas (Recibir 30 de Oro)";
		Escribir "=========================================";
		Escribir " Espacios ocupados: [ ", totalReliquiasEquipadas, " / 5 ]";
		Escribir "=========================================";
		Escribir Sin Saltar " Elige tu opcion (1, 2 o 3): ";
		Leer opcionCofre;
		
		Si opcionCofre <> "1" Y opcionCofre <> "2" Y opcionCofre <> "3" Entonces
			Escribir "Entrada no valida. Elige 1, 2 o 3.";
			Esperar 2 Segundos;
		FinSi
	Hasta Que opcionCofre == "1" O opcionCofre == "2" O opcionCofre == "3"
	
	Si opcionCofre == "1" O opcionCofre == "2" Entonces
		Si opcionCofre == "1" Entonces
			reliquiaElegida <- nombre1;
		SiNo
			reliquiaElegida <- nombre2;
		FinSi
		
		// Si hay espacio libre, se equipa de inmediato
		Si totalReliquiasEquipadas < 5 Entonces
			totalReliquiasEquipadas <- totalReliquiasEquipadas + 1;
			inventarioReliquias(totalReliquiasEquipadas) <- reliquiaElegida;
			Escribir "¡Has obtenido y equipado: ", reliquiaElegida, "!";
			
			// [IDs 1, 5, 6] Aplicar bonificaciones de estadisticas base inmediatas
			Si reliquiaElegida == "Mazo de Obsidiana" Entonces
				danojugador <- danojugador + 12; 
			SiNo
				Si reliquiaElegida == "Excalibur" Entonces
					danojugador <- danojugador + 10;
				SiNo
					Si reliquiaElegida == "Anillo de Defensa" Entonces
						vidaMaxima <- vidaMaxima + 25;
						vidaActual <- vidaActual + 25; 
					FinSi
				FinSi
			FinSi
			Esperar 3 Segundos;
			
		SiNo
			// SI EL INVENTARIO ESTA LLENO (5/5), MENU DE REEMPLAZO TACTICO
			Repetir
				Limpiar Pantalla;
				Escribir "=========================================";
				Escribir "      ¡INVENTARIO LLENO (5 / 5)!         ";
				Escribir "=========================================";
				Escribir " Intentas equipar: ", reliquiaElegida;
				Escribir " Selecciona que slot deseas reemplazar:";
				Escribir "-----------------------------------------";
				Para i <- 1 Hasta 5 Hacer
					Escribir " [", i, "] Reemplazar a: ", inventarioReliquias(i);
				FinPara
				Escribir " [6] Arrepentirse y llevarse 30 de oro";
				Escribir "=========================================";
				Escribir Sin Saltar "Elige una opcion (1 a 6): ";
				Leer opcionReemplazo;
				
				Si opcionReemplazo <> "1" Y opcionReemplazo <> "2" Y opcionReemplazo <> "3" Y opcionReemplazo <> "4" Y opcionReemplazo <> "5" Y opcionReemplazo <> "6" Entonces
					Escribir "Entrada no valida. Elige del 1 al 6.";
					Esperar 2 Segundos;
				FinSi
			Hasta Que opcionReemplazo == "1" O opcionReemplazo == "2" O opcionReemplazo == "3" O opcionReemplazo == "4" O opcionReemplazo == "5" O opcionReemplazo == "6"
			
			Si opcionReemplazo <> "6" Entonces
				Si opcionReemplazo == "1" Entonces
					slotAElegir <- 1;
				FinSi
				Si opcionReemplazo == "2" Entonces
					slotAElegir <- 2;
				FinSi
				Si opcionReemplazo == "3" Entonces
					slotAElegir <- 3;
				FinSi
				Si opcionReemplazo == "4" Entonces
					slotAElegir <- 4;
				FinSi
				Si opcionReemplazo == "5" Entonces
					slotAElegir <- 5;
				FinSi
				
				reliquiaDescartada <- inventarioReliquias(slotAElegir);
				
				// Revertir estadisticas base si la reliquia descartada las otorgaba
				Si reliquiaDescartada == "Mazo de Obsidiana" Entonces
					danojugador <- danojugador - 12;
				SiNo
					Si reliquiaDescartada == "Excalibur" Entonces
						danojugador <- danojugador - 10;
					SiNo
						Si reliquiaDescartada == "Anillo de Defensa" Entonces
							vidaMaxima <- vidaMaxima - 25;
							Si vidaActual > vidaMaxima Entonces
								vidaActual <- vidaMaxima;
							FinSi
						FinSi
					FinSi
				FinSi
				
				Escribir "¡Has descartado a ", reliquiaDescartada, " y equipado ", reliquiaElegida, "!";
				inventarioReliquias(slotAElegir) <- reliquiaElegida;
				
				// Aplicar bonificaciones si la nueva reliquia da stats inmediatos
				Si reliquiaElegida == "Mazo de Obsidiana" Entonces
					danojugador <- danojugador + 12;
				SiNo
					Si reliquiaElegida == "Excalibur" Entonces
						danojugador <- danojugador + 10;
					SiNo
						Si reliquiaElegida == "Anillo de Defensa" Entonces
							vidaMaxima <- vidaMaxima + 25;
							vidaActual <- vidaActual + 25;
						FinSi
					FinSi
				FinSi
				
				Esperar 3 Segundos;
			SiNo
				oro <- oro + 30;
				Escribir "Has decidido conservar tus reliquias. Obtienes 30 de oro.";
				Esperar 2.5 Segundos;
			FinSi
		FinSi
	SiNo
		oro <- oro + 30;
		Escribir "Has rechazado las reliquias. Obtienes 30 de oro.";
		Esperar 2.5 Segundos;
	FinSi
	Limpiar Pantalla;
FinSubProceso

// -----------------------------------------------------------------
// MAPA COMPACTO DE LA MAZMORRA (Con Pistas Ambientales y Tienda)
// -----------------------------------------------------------------
SubProceso MostrarMapaCompacto(PasoActual Por Valor, oro Por Valor, enemigoIzquierda Por Valor, enemigoDerecha Por Valor, ultimaSalaSuperada Por Valor)
	Definir pistaIzquierda, pistaDerecha Como Caracter;
	
	ObtenerPistaSala(enemigoIzquierda, pistaIzquierda);
	ObtenerPistaSala(enemigoDerecha, pistaDerecha);
	
	Limpiar Pantalla;
	Escribir "===================================================================";
	Escribir "                       MAPA DE LA MAZMORRA                         ";
	Escribir "===================================================================";
	
	Si PasoActual > 1 Entonces
		Escribir " [Rastro] Piso ", (PasoActual - 1), " (Sala ", ultimaSalaSuperada, ") -> Piso ", PasoActual, " (Actual)";
	SiNo
		Escribir " [Inicio de aventura] -> Piso 1 (Actual)";
	FinSi
	
	Escribir " Oro actual: ", oro, " monedas";
	Escribir "-------------------------------------------------------------------";
	Escribir "                         ELIGE TU CAMINO:                          ";
	Escribir " ";
	Escribir "   [1] -> ", pistaIzquierda;
	Escribir "   [2] -> ", pistaDerecha;
	Escribir "   [3] -> Visitar la Tienda del Mercader";
	Escribir "===================================================================";
FinSubProceso

// -----------------------------------------------------------------
// TIENDA DEL MERCADER
// -----------------------------------------------------------------
SubProceso SalaTienda(vidaActual Por Referencia, vidaMaxima Por Referencia, danojugador Por Referencia, cantidadpociones Por Referencia, oro Por Referencia)
	Definir opciontienda Como Caracter;
	
	Repetir
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir "           TIENDA DEL MERCADER           ";
		Escribir "=========================================";
		Escribir "Tu Oro disponible: ", oro, " monedas";
		Escribir "Tu Vida: ", vidaActual, " / ", vidaMaxima;
		Escribir "Tu Dano actual: ", danojugador;
		Escribir "Tus Pociones: ", cantidadpociones;
		Escribir "-----------------------------------------";
		Escribir " [1] Comprar 1 Pocion extra       (Costo: 20 oro)";
		Escribir " [2] Frasco de Vida Maxima (+50 HP) (Costo: 50 oro)";
		Escribir " [3] Afilar arma (+10 de dano)      (Costo: 40 oro)";
		Escribir " [4] Salir de la tienda";
		Escribir "=========================================";
		Escribir Sin Saltar "Elige una opcion: ";
		Leer opciontienda;
		
		Si opciontienda == "1" Entonces
			Si oro >= 20 Entonces
				oro <- oro - 20;
				cantidadpociones <- cantidadpociones + 1;
				Escribir "¡Has comprado 1 pocion extra!";
			SiNo
				Escribir "¡No tienes suficiente oro (requieres 20)!";
			FinSi
			Esperar 2.5 Segundos;
		SiNo
			Si opciontienda == "2" Entonces
				Si oro >= 50 Entonces
					oro <- oro - 50;
					vidaMaxima <- vidaMaxima + 50;
					vidaActual <- vidaActual + 50; 
					Escribir "¡Te bebiste un tonico supremo! Tu vida maxima aumenta.";
				SiNo
					Escribir "¡No tienes suficiente oro (requieres 50)!";
				FinSi
				Esperar 2.5 Segundos;
			SiNo
				Si opciontienda == "3" Entonces
					Si oro >= 40 Entonces
						oro <- oro - 40;
						danojugador <- danojugador + 10;
						Escribir "¡Afilaste tu arma! Tu dano aumenta.";
					SiNo
						Escribir "¡No tienes suficiente oro (requieres 40)!";
					FinSi
					Esperar 2.5 Segundos;
				SiNo
					Si opciontienda == "4" Entonces
						Escribir "Sales de la tienda y continuas tu camino...";
						Esperar 2 Segundos;
					SiNo
						Escribir "Opcion invalida. Intentalo de nuevo.";
						Esperar 2.5 Segundos;
					FinSi
				FinSi
			FinSi
		FinSi
	Hasta Que opciontienda == "4"
FinSubProceso

// -----------------------------------------------------------------
// SUBPROCESOS DE COMBATE (Con Defensa al 50% y Orquestador de Reliquias)
// -----------------------------------------------------------------

// --- SALA 1: DOS ZOMBIES ---
SubProceso SalaGenerada1(vidaActual Por Referencia, vidaMaxima Por Valor, danojugador Por Valor, cantidadpociones Por Referencia, inventarioReliquias Por Referencia, totalReliquiasEquipadas Por Valor, oro Por Referencia)
	Definir z1, z2, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy Como Entero;
	Definir accion Como Caracter;
	Definir defendiendo Como Logico;
	z1 <- 50;
	z2 <- 50;
	dummy <- 0;
	
	Repetir
		defendiendo <- Falso;
		
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=== SALA 1: DOS ZOMBIES ===";
	        Escribir "HP Jugador: ", vidaActual, " / ", vidaMaxima;
	        
	        Si z1 <= 0 Entonces 
				Escribir "Zombi 1 HP: || M U E R T O ||"; 
			SiNo 
				Escribir "Zombi 1 HP: ", z1; 
			FinSi
			
	        Si z2 <= 0 Entonces 
				Escribir "Zombi 2 HP: || M U E R T O ||"; 
			SiNo 
				Escribir "Zombi 2 HP: ", z2; 
			FinSi
	        
	        Escribir "-----------------------------------------";
	        Escribir "1: Atacar | 2: Defender | 3: Inventario";
	        Leer accion;
			
			Si accion == "3" Entonces
				VerInventarioCombate(cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danojugador, oro);
				accion <- "0"; 
			SiNo
				Si accion <> "1" Y accion <> "2" Entonces
					Escribir "Accion invalida. Selecciona 1, 2 o 3.";
					Esperar 2 Segundos;
				FinSi
			FinSi
	    Hasta Que accion == "1" O accion == "2"
	    
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir "           ACCION DEL TURNO              ";
		Escribir "=========================================";
		
		// 1. Efectos pasivos de inicio de turno (Libro Volcanico)
		OrquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
		Si danoAreaTurno > 0 Entonces
			Si z1 > 0 Entonces
				z1 <- z1 - danoAreaTurno;
			FinSi
			Si z2 > 0 Entonces
				z2 <- z2 - danoAreaTurno;
			FinSi
		FinSi
		
		// 2. Accion del jugador
	    Si accion == "1" Entonces
			Si z1 > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				z1 <- z1 - danoFinal;
				Escribir "-> Atacaste al Zombi 1 causando ", danoFinal, " de dano.";
			FinSi
			Si z2 > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				z2 <- z2 - danoFinal;
				Escribir "-> Atacaste al Zombi 2 causando ", danoFinal, " de dano.";
			FinSi
	    SiNo
			defendiendo <- Verdadero;
	        Escribir "-> Te pones en guardia. El dano recibido se reduce en un 50%.";
	    FinSi
	    
		Escribir "-----------------------------------------";
		
		// 3. Turno de enemigos (Aplica Defensa 50%, Bomba de Humo y Collar de Espinas)
	    Si z1 > 0 Entonces
			danoEnemigo <- 10;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
	        vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- El Zombi 1 te ataca e inflige ", danoEnemigo, " de dano.";
			Si danoReflejado > 0 Entonces
				z1 <- z1 - danoReflejado;
			FinSi
	    FinSi
	    Si z2 > 0 Entonces
			danoEnemigo <- 10;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
	        vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- El Zombi 2 te ataca e inflige ", danoEnemigo, " de dano.";
			Si danoReflejado > 0 Entonces
				z2 <- z2 - danoReflejado;
			FinSi
	    FinSi
		
		Escribir "=========================================";
		Escribir "Presiona una tecla para continuar...";
		Esperar Tecla;
		
	Hasta Que (z1 <= 0 Y z2 <= 0) O vidaActual <= 0
FinSubProceso

// --- SALA 2: ZOMBI Y ESQUELETO ---
SubProceso SalaGenerada2(vidaActual Por Referencia, vidaMaxima Por Valor, danojugador Por Valor, cantidadpociones Por Referencia, inventarioReliquias Por Referencia, totalReliquiasEquipadas Por Valor, oro Por Referencia)
	Definir zombieHP, esqueletoHP, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy Como Entero;
	Definir accion Como Caracter;
	Definir defendiendo Como Logico;
	zombieHP <- 50;
	esqueletoHP <- 70;
	dummy <- 0;
	
	Repetir
		defendiendo <- Falso;
		
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=== SALA 2: ZOMBI Y ESQUELETO ===";
	        Escribir "HP Jugador: ", vidaActual, " / ", vidaMaxima;
	        
	        Si zombieHP <= 0 Entonces 
				Escribir "Zombi HP: || M U E R T O ||"; 
			SiNo 
				Escribir "Zombi HP: ", zombieHP; 
			FinSi
			
	        Si esqueletoHP <= 0 Entonces 
				Escribir "Esqueleto HP: || M U E R T O ||"; 
			SiNo 
				Escribir "Esqueleto HP: ", esqueletoHP; 
			FinSi
	        
	        Escribir "-----------------------------------------";
	        Escribir "1: Atacar | 2: Defender | 3: Inventario";
	        Leer accion;
			
			Si accion == "3" Entonces
				VerInventarioCombate(cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danojugador, oro);
				accion <- "0";
			SiNo
				Si accion <> "1" Y accion <> "2" Entonces
					Escribir "Accion invalida. Selecciona 1, 2 o 3.";
					Esperar 2 Segundos;
				FinSi
			FinSi
	    Hasta Que accion == "1" O accion == "2"
	    
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir "           ACCION DEL TURNO              ";
		Escribir "=========================================";
		
		OrquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
		Si danoAreaTurno > 0 Entonces
			Si zombieHP > 0 Entonces
				zombieHP <- zombieHP - danoAreaTurno;
			FinSi
			Si esqueletoHP > 0 Entonces
				esqueletoHP <- esqueletoHP - danoAreaTurno;
			FinSi
		FinSi
		
	    Si accion == "1" Entonces
			Si zombieHP > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				zombieHP <- zombieHP - danoFinal;
				Escribir "-> Atacaste al Zombi causando ", danoFinal, " de dano.";
			FinSi
			Si esqueletoHP > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				esqueletoHP <- esqueletoHP - danoFinal;
				Escribir "-> Atacaste al Esqueleto causando ", danoFinal, " de dano.";
			FinSi
	    SiNo
			defendiendo <- Verdadero;
	        Escribir "-> Te proteges del impacto. El dano recibido se reduce en un 50%.";
	    FinSi
	    
		Escribir "-----------------------------------------";
		
	    Si zombieHP > 0 Entonces
			danoEnemigo <- 10;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
	        vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- El Zombi te ataca e inflige ", danoEnemigo, " de dano.";
			Si danoReflejado > 0 Entonces
				zombieHP <- zombieHP - danoReflejado;
			FinSi
	    FinSi
	    Si esqueletoHP > 0 Entonces
			danoEnemigo <- 15;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
	        vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- El Esqueleto te ataca e inflige ", danoEnemigo, " de dano.";
			Si danoReflejado > 0 Entonces
				esqueletoHP <- esqueletoHP - danoReflejado;
			FinSi
	    FinSi
		
		Escribir "=========================================";
		Escribir "Presiona una tecla para continuar...";
		Esperar Tecla;
		
	Hasta Que (zombieHP <= 0 Y esqueletoHP <= 0) O vidaActual <= 0
FinSubProceso

// --- SALA 3: SLIME Y ESQUELETO ---
SubProceso SalaGenerada3(vidaActual Por Referencia, vidaMaxima Por Valor, danojugador Por Valor, cantidadpociones Por Referencia, inventarioReliquias Por Referencia, totalReliquiasEquipadas Por Valor, oro Por Referencia)
	Definir slimeHP, esqueletoHP, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy Como Entero;
	Definir accion Como Caracter;
	Definir defendiendo Como Logico;
	slimeHP <- 40;
	esqueletoHP <- 70;
	dummy <- 0;
	
	Repetir
		defendiendo <- Falso;
		
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=== SALA 3: SLIME Y ESQUELETO ===";
	        Escribir "HP Jugador: ", vidaActual, " / ", vidaMaxima;
	        
	        Si slimeHP <= 0 Entonces 
				Escribir "Slime HP: || M U E R T O ||"; 
			SiNo 
				Escribir "Slime HP: ", slimeHP; 
			FinSi
			
	        Si esqueletoHP <= 0 Entonces 
				Escribir "Esqueleto HP: || M U E R T O ||"; 
			SiNo 
				Escribir "Esqueleto HP: ", esqueletoHP; 
			FinSi
	        
	        Escribir "-----------------------------------------";
	        Escribir "1: Atacar | 2: Defender | 3: Inventario";
	        Leer accion;
			
			Si accion == "3" Entonces
				VerInventarioCombate(cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danojugador, oro);
				accion <- "0";
			SiNo
				Si accion <> "1" Y accion <> "2" Entonces
					Escribir "Accion invalida. Selecciona 1, 2 o 3.";
					Esperar 2 Segundos;
				FinSi
			FinSi
	    Hasta Que accion == "1" O accion == "2"
	    
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir "           ACCION DEL TURNO              ";
		Escribir "=========================================";
		
		OrquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
		Si danoAreaTurno > 0 Entonces
			Si slimeHP > 0 Entonces
				slimeHP <- slimeHP - danoAreaTurno;
			FinSi
			Si esqueletoHP > 0 Entonces
				esqueletoHP <- esqueletoHP - danoAreaTurno;
			FinSi
		FinSi
		
	    Si accion == "1" Entonces
			Si slimeHP > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				slimeHP <- slimeHP - danoFinal;
				Escribir "-> Atacaste al Slime causando ", danoFinal, " de dano.";
			FinSi
			Si esqueletoHP > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				esqueletoHP <- esqueletoHP - danoFinal;
				Escribir "-> Atacaste al Esqueleto causando ", danoFinal, " de dano.";
			FinSi
	    SiNo
			defendiendo <- Verdadero;
	        Escribir "-> Te defiendes. El dano recibido se reduce en un 50%.";
	    FinSi
		
		Escribir "-----------------------------------------";
		
	    Si slimeHP > 0 Entonces
			danoEnemigo <- 5;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
	        vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- El Slime te ataca e inflige ", danoEnemigo, " de dano.";
			Si danoReflejado > 0 Entonces
				slimeHP <- slimeHP - danoReflejado;
			FinSi
	    FinSi
	    Si esqueletoHP > 0 Entonces
			danoEnemigo <- 15;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
	        vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- El Esqueleto te ataca e inflige ", danoEnemigo, " de dano.";
			Si danoReflejado > 0 Entonces
				esqueletoHP <- esqueletoHP - danoReflejado;
			FinSi
	    FinSi
		
		Escribir "=========================================";
		Escribir "Presiona una tecla para continuar...";
		Esperar Tecla;
		
	Hasta Que (slimeHP <= 0 Y esqueletoHP <= 0) O vidaActual <= 0
FinSubProceso

// --- SALA 4: GOLEM Y ZOMBI ---
SubProceso SalaGenerada4(vidaActual Por Referencia, vidaMaxima Por Valor, danojugador Por Valor, cantidadpociones Por Referencia, inventarioReliquias Por Referencia, totalReliquiasEquipadas Por Valor, oro Por Referencia)
	Definir golemHP, zombieHP, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy Como Entero;
	Definir accion Como Caracter;
	Definir golemAtaca, defendiendo Como Logico;
	golemHP <- 200;
	zombieHP <- 50;
	golemAtaca <- Falso;
	dummy <- 0;
	
	Repetir
		defendiendo <- Falso;
		
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=== SALA 4: GOLEM Y ZOMBI ===";
	        Escribir "HP Jugador: ", vidaActual, " / ", vidaMaxima;
	        
	        Si golemHP <= 0 Entonces 
				Escribir "Golem HP: || M U E R T O ||"; 
			SiNo 
				Escribir "Golem HP: ", golemHP; 
			FinSi
			
	        Si zombieHP <= 0 Entonces 
				Escribir "Zombi HP: || M U E R T O ||"; 
			SiNo 
				Escribir "Zombi HP: ", zombieHP; 
			FinSi
	        
	        Si golemAtaca Entonces
		        Escribir "[!] ¡El Golem esta listo para atacar este turno!";
	        SiNo
		        Escribir "[*] El Golem esta cargando energia...";
	        FinSi
	        
	        Escribir "-----------------------------------------";
	        Escribir "1: Atacar | 2: Defender | 3: Inventario";
	        Leer accion;
			
			Si accion == "3" Entonces
				VerInventarioCombate(cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danojugador, oro);
				accion <- "0";
			SiNo
				Si accion <> "1" Y accion <> "2" Entonces
					Escribir "Accion invalida. Selecciona 1, 2 o 3.";
					Esperar 2 Segundos;
				FinSi
			FinSi
	    Hasta Que accion == "1" O accion == "2"
	    
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir "           ACCION DEL TURNO              ";
		Escribir "=========================================";
		
		OrquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
		Si danoAreaTurno > 0 Entonces
			Si golemHP > 0 Entonces
				golemHP <- golemHP - danoAreaTurno;
			FinSi
			Si zombieHP > 0 Entonces
				zombieHP <- zombieHP - danoAreaTurno;
			FinSi
		FinSi
		
	    Si accion == "1" Entonces
			Si golemHP > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				golemHP <- golemHP - danoFinal;
				Escribir "-> Atacaste al Golem causando ", danoFinal, " de dano.";
			FinSi
			Si zombieHP > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				zombieHP <- zombieHP - danoFinal;
				Escribir "-> Atacaste al Zombi causando ", danoFinal, " de dano.";
			FinSi
	    SiNo
			defendiendo <- Verdadero;
	        Escribir "-> Te defiendes de los ataques entrantes. El dano recibido se reduce en un 50%.";
	    FinSi
	    
		Escribir "-----------------------------------------";
		
	    Si zombieHP > 0 Entonces
			danoEnemigo <- 10;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
	        vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- El Zombi te ataca e inflige ", danoEnemigo, " de dano.";
			Si danoReflejado > 0 Entonces
				zombieHP <- zombieHP - danoReflejado;
			FinSi
	    FinSi
	    
	    Si golemHP > 0 Entonces
	        Si golemAtaca Entonces
				danoEnemigo <- 30;
				Si defendiendo Entonces
					danoEnemigo <- trunc(danoEnemigo / 2);
				FinSi
				OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
	            vidaActual <- vidaActual - danoEnemigo;
				Escribir "<- ¡El Golem desata su ataque masivo e inflige ", danoEnemigo, " de dano!";
				Si danoReflejado > 0 Entonces
					golemHP <- golemHP - danoReflejado;
				FinSi
	            golemAtaca <- Falso;
	        SiNo
				Escribir "<- El Golem ruge acumulando poder (sin dano este turno).";
	            golemAtaca <- Verdadero;
	        FinSi
	    FinSi
	    
		Escribir "=========================================";
		Escribir "Presiona una tecla para continuar...";
		Esperar Tecla;
		
	Hasta Que (golemHP <= 0 Y zombieHP <= 0) O vidaActual <= 0
FinSubProceso

// --- SALA 5: TRES SLIMES ---
SubProceso SalaGenerada5(vidaActual Por Referencia, vidaMaxima Por Valor, danojugador Por Valor, cantidadpociones Por Referencia, inventarioReliquias Por Referencia, totalReliquiasEquipadas Por Valor, oro Por Referencia)
	Definir s1, s2, s3, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy Como Entero;
	Definir accion Como Caracter;
	Definir defendiendo Como Logico;
	s1 <- 40;
	s2 <- 40;
	s3 <- 40;
	dummy <- 0;
	
	Repetir
		defendiendo <- Falso;
		
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=== SALA 5: TRES SLIMES ===";
	        Escribir "HP Jugador: ", vidaActual, " / ", vidaMaxima;
	        
	        Si s1 <= 0 Entonces 
				Escribir "Slime 1: || M U E R T O ||"; 
			SiNo 
				Escribir "Slime 1: ", s1; 
			FinSi
			
	        Si s2 <= 0 Entonces 
				Escribir "Slime 2: || M U E R T O ||"; 
			SiNo 
				Escribir "Slime 2: ", s2; 
			FinSi
			
	        Si s3 <= 0 Entonces 
				Escribir "Slime 3: || M U E R T O ||"; 
			SiNo 
				Escribir "Slime 3: ", s3; 
			FinSi
	        
	        Escribir "-----------------------------------------";
	        Escribir "1: Atacar | 2: Defender | 3: Inventario";
	        Leer accion;
			
			Si accion == "3" Entonces
				VerInventarioCombate(cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danojugador, oro);
				accion <- "0";
			SiNo
				Si accion <> "1" Y accion <> "2" Entonces
					Escribir "Accion invalida. Selecciona 1, 2 o 3.";
					Esperar 2 Segundos;
				FinSi
			FinSi
	    Hasta Que accion == "1" O accion == "2"
	    
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir "           ACCION DEL TURNO              ";
		Escribir "=========================================";
		
		OrquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
		Si danoAreaTurno > 0 Entonces
			Si s1 > 0 Entonces
				s1 <- s1 - danoAreaTurno;
			FinSi
			Si s2 > 0 Entonces
				s2 <- s2 - danoAreaTurno;
			FinSi
			Si s3 > 0 Entonces
				s3 <- s3 - danoAreaTurno;
			FinSi
		FinSi
		
	    Si accion == "1" Entonces
			Si s1 > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				s1 <- s1 - danoFinal;
				Escribir "-> Atacaste al Slime 1 causando ", danoFinal, " de dano.";
			FinSi
			Si s2 > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				s2 <- s2 - danoFinal;
				Escribir "-> Atacaste al Slime 2 causando ", danoFinal, " de dano.";
			FinSi
			Si s3 > 0 Entonces
				OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
				s3 <- s3 - danoFinal;
				Escribir "-> Atacaste al Slime 3 causando ", danoFinal, " de dano.";
			FinSi
	    SiNo
			defendiendo <- Verdadero;
	        Escribir "-> Te proteges de la ofensiva. El dano recibido se reduce en un 50%.";
	    FinSi
	    
		Escribir "-----------------------------------------";
		
	    Si s1 > 0 Entonces
			danoEnemigo <- 5;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
		    vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- El Slime 1 te ataca e inflige ", danoEnemigo, " de dano.";
			Si danoReflejado > 0 Entonces
				s1 <- s1 - danoReflejado;
			FinSi
	    FinSi
	    Si s2 > 0 Entonces
			danoEnemigo <- 5;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
		    vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- El Slime 2 te ataca e inflige ", danoEnemigo, " de dano.";
			Si danoReflejado > 0 Entonces
				s2 <- s2 - danoReflejado;
			FinSi
	    FinSi
	    Si s3 > 0 Entonces
			danoEnemigo <- 5;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
		    vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- El Slime 3 te ataca e inflige ", danoEnemigo, " de dano.";
			Si danoReflejado > 0 Entonces
				s3 <- s3 - danoReflejado;
			FinSi
	    FinSi
	    
		Escribir "=========================================";
		Escribir "Presiona una tecla para continuar...";
		Esperar Tecla;
		
	Hasta Que (s1 <= 0 Y s2 <= 0 Y s3 <= 0) O vidaActual <= 0
FinSubProceso

// -----------------------------------------------------------------
// SALA DE JEFE FINAL: DRAGÓN COLOSAL
// -----------------------------------------------------------------
SubProceso SalaJefeFinal(vidaActual Por Referencia, vidaMaxima Por Valor, danojugador Por Valor, cantidadpociones Por Referencia, inventarioReliquias Por Referencia, totalReliquiasEquipadas Por Valor, oro Por Referencia)
	Definir dragonHP, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy Como Entero;
	Definir accion Como Caracter;
	Definir defendiendo Como Logico;
	Definir tipoAtaqueDragon, turnosRecargaLlamarada Como Entero;
	Definir dragonCargandoFuego Como Logico;
	
	dragonHP <- 400;
	turnosRecargaLlamarada <- 0;
	dragonCargandoFuego <- Falso;
	dummy <- 0;
	
	Repetir
		defendiendo <- Falso;
		
		// Gestion de recarga de la llamarada (Cooldown de 3 turnos)
		Si turnosRecargaLlamarada > 0 Entonces
			turnosRecargaLlamarada <- turnosRecargaLlamarada - 1;
		FinSi
		
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=========================================";
	        Escribir "   ¡BATALLA FINAL: DRAGON COLOSAL!       ";
	        Escribir "=========================================";
	        Escribir "HP Jugador: ", vidaActual, " / ", vidaMaxima;
	        Escribir "Dragon Colosal HP: ", dragonHP, " / 400";
	        Escribir "-----------------------------------------";
			
			Si dragonCargandoFuego Entonces
				Escribir "[!] ¡ADVERTENCIA! El Dragon esta acumulando fuego en su garganta...";
				Escribir "[!] ¡Llamarada devastadora inminente para el siguiente turno!";
			SiNo
				Escribir "[*] El Dragon acecha y ruge con furia.";
			FinSi
			
	        Escribir "-----------------------------------------";
	        Escribir "1: Atacar | 2: Defender | 3: Inventario";
	        Leer accion;
			
			Si accion == "3" Entonces
				VerInventarioCombate(cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danojugador, oro);
				accion <- "0";
			SiNo
				Si accion <> "1" Y accion <> "2" Entonces
					Escribir "Accion invalida. Selecciona 1, 2 o 3.";
					Esperar 2 Segundos;
				FinSi
			FinSi
	    Hasta Que accion == "1" O accion == "2"
	    
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir "           ACCION DEL TURNO              ";
		Escribir "=========================================";
		
		// 1. Efectos pasivos de inicio de turno (Libro Volcanico)
		OrquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
		Si danoAreaTurno > 0 Entonces
			dragonHP <- dragonHP - danoAreaTurno;
		FinSi
		
		// 2. Accion del jugador
	    Si accion == "1" Entonces
			OrquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
			dragonHP <- dragonHP - danoFinal;
			Escribir "-> Atacaste al Dragon Colosal causando ", danoFinal, " de dano.";
	    SiNo
			defendiendo <- Verdadero;
	        Escribir "-> Te pones en guardia. El dano recibido se reduce en un 50%.";
	    FinSi
	    
		Escribir "-----------------------------------------";
		
		// 3. Turno del Dragon Colosal
		Si dragonCargandoFuego Entonces
			// Descarga de la llamarada cargada (100 de dano base)
			danoEnemigo <- 100;
			Si defendiendo Entonces
				danoEnemigo <- trunc(danoEnemigo / 2);
			FinSi
			OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
			vidaActual <- vidaActual - danoEnemigo;
			Escribir "<- ¡El Dragon desata su LLAMARADA DE FUEGO e inflige ", danoEnemigo, " de dano!";
			
			dragonCargandoFuego <- Falso;
			turnosRecargaLlamarada <- 3; // Inicia enfriamiento de 3 turnos
		SiNo
			// Sortear ataque aleatorio (1: Garra, 2: Cola, 3: Llamarada)
			Si turnosRecargaLlamarada == 0 Entonces
				tipoAtaqueDragon <- Aleatorio(1, 3);
			SiNo
				tipoAtaqueDragon <- Aleatorio(1, 2); // En recarga solo usa Garra o Cola
			FinSi
			
			Si tipoAtaqueDragon == 1 Entonces
				// Ataque con garra (20 de dano base)
				danoEnemigo <- 20;
				Si defendiendo Entonces
					danoEnemigo <- trunc(danoEnemigo / 2);
				FinSi
				OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
				vidaActual <- vidaActual - danoEnemigo;
				Escribir "<- El Dragon te golpea con su Garra e inflige ", danoEnemigo, " de dano.";
				
			SiNo
				Si tipoAtaqueDragon == 2 Entonces
					// Ataque con cola (30 de dano base)
					danoEnemigo <- 30;
					Si defendiendo Entonces
						danoEnemigo <- trunc(danoEnemigo / 2);
					FinSi
					OrquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danojugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
					vidaActual <- vidaActual - danoEnemigo;
					Escribir "<- El Dragon te barre con su Cola e inflige ", danoEnemigo, " de dano.";
					
				SiNo
					// Inicia la carga de la llamarada para el siguiente turno
					dragonCargandoFuego <- Verdadero;
					Escribir "<- ¡El Dragon respira hondo y comienza a cargar una Llamarada de Fuego!";
				FinSi
			FinSi
		FinSi
		
		// Aplicar espinas si las tiene equipadas
		Si danoReflejado > 0 Entonces
			dragonHP <- dragonHP - danoReflejado;
		FinSi
		
		Escribir "=========================================";
		Escribir "Presiona una tecla para continuar...";
		Esperar Tecla;
		
	Hasta Que dragonHP <= 0 O vidaActual <= 0
FinSubProceso

// -----------------------------------------------------------------
// ALGORITMO PRINCIPAL
// -----------------------------------------------------------------
Algoritmo DungeonCrawl
	Definir PasoActual, vidaActual, vidaMaxima, cantidadpociones, enemigoIzquierda, enemigoDerecha, oro Como Entero;
	Definir tipoSalaElegida, dummy1, dummy2, dummy3, dummy4 Como Entero; 
	Definir opcioncamino Como Caracter; 
	Definir gano Como Logico;
	Definir danojugador Como Entero;
	
	// Inventario de Reliquias (6 de tamano para soportar 5 slots del 1 al 5)
	Definir inventarioReliquias Como Caracter;
	Dimensionar inventarioReliquias(6);
	Definir totalReliquiasEquipadas, i Como Entero;
	totalReliquiasEquipadas <- 0;
	
	Para i <- 1 Hasta 5 Hacer
		inventarioReliquias(i) <- "Vacio";
	FinPara
	
	// Variables iniciales
	danojugador <- 25;
	PasoActual <- 1;
	vidaMaxima <- 200;
	vidaActual <- 200;
	cantidadpociones <- 0;
	oro <- 0;
	tipoSalaElegida <- 0;
	dummy1 <- 0;
	dummy2 <- 0;
	dummy3 <- 0;
	dummy4 <- 0;
	Definir ultimaSalaSuperada Como Entero;
	ultimaSalaSuperada <- 0;
	
	// =================================================================
	// PANTALLA DE INICIO / INTRODUCCION DEL JUEGO
	// =================================================================
	Limpiar Pantalla;
	Escribir "=========================================================================";
	Escribir "  ____  ____  _____ _   _ ____   ___    ____  _   _ _   _  ____ _____ ___ _   _ ";
	Escribir " |  _ \/ ___|| ____| | | |  _ \ / _ \  |  _ \| | | | \ | |/ ___| ____/ _ \| \ | |";
	Escribir " | |_) \___ \|  _| | | | | | | | | | | | | | | | | |  \| | |  _|  _|| | | |  \| |";
	Escribir " |  __/ ___) | |___| |_| | |_| | |_| | | |_| | |_| | |\  | |_| | |__| |_| | |\  |";
	Escribir " |_|   |____/|_____|\___/|____/ \___/  |____/ \___/|_| \_|\____|_____\___/|_| \_|";
	Escribir "=========================================================================";
	Escribir "";
	Escribir "  COMO JUGAR:";
	Escribir "  * Selecciona tus movimientos y ataques usando opciones multiples.";
	Escribir "  * Explora y sobrevive a traves de 8 pisos llenos de monstruos.";
	Escribir "  * Equipa reliquias pasivas y visita al mercader para fortalecerte.";
	Escribir "  * Al final te espera un Jefe Colosal: derrotarlo te dara la victoria.";
	Escribir "";
	Escribir "=========================================================================";
	Escribir "";
	Escribir "                Oprime cualquier tecla para empezar...";
	Esperar Tecla;
	Limpiar Pantalla;

	
	Repetir
		Mientras PasoActual <= 8 Hacer
			
			gano <- Falso;
			
			// Generacion pura de rutas de combate (1 al 5) asegurando que sean distintas
			enemigoIzquierda <- Aleatorio(1, 5);
			enemigoDerecha <- Aleatorio(1, 5);
			Mientras enemigoDerecha == enemigoIzquierda Hacer
				enemigoDerecha <- Aleatorio(1, 5);
			FinMientras
			
			// Bucle de seleccion de camino en el mapa (Permite entrar a la tienda en opcion 3)
			Repetir
				MostrarMapaCompacto(PasoActual, oro, enemigoIzquierda, enemigoDerecha, ultimaSalaSuperada);
				Escribir Sin Saltar "      Elige tu opcion (1, 2 o 3): ";
				Leer opcioncamino;
				
				Si opcioncamino == "3" Entonces
					SalaTienda(vidaActual, vidaMaxima, danojugador, cantidadpociones, oro);
				SiNo
					Si opcioncamino <> "1" Y opcioncamino <> "2" Entonces
						Escribir "Entrada no valida. Elige 1, 2 o 3.";
						Esperar 2 Segundos;
					FinSi
				FinSi
			Hasta Que opcioncamino == "1" O opcioncamino == "2"
			
			// Ejecutar subproceso de combate segun el camino elegido
			Si opcioncamino == "1" Entonces
				tipoSalaElegida <- enemigoIzquierda;
				Segun enemigoIzquierda Hacer
					1: 
						SalaGenerada1(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
					2: 
						SalaGenerada2(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
					3: 
						SalaGenerada3(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
					4: 
						SalaGenerada4(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
					5: 
						SalaGenerada5(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
				FinSegun
			SiNo
				tipoSalaElegida <- enemigoDerecha;
				Segun enemigoDerecha Hacer
					1: 
						SalaGenerada1(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
					2: 
						SalaGenerada2(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
					3: 
						SalaGenerada3(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
					4: 
						SalaGenerada4(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
					5: 
						SalaGenerada5(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
				FinSegun
			FinSi
			
			// Analisis tras finalizar la sala
			Limpiar Pantalla;
			Escribir "SECCION COMPLETADA";
			Esperar 2 Segundos;
			
			Si vidaActual > 0 Entonces
				ultimaSalaSuperada <- tipoSalaElegida;
				PasoActual <- PasoActual + 1;
				gano <- Verdadero;
				
				// Recompensas de oro y bono de Monedero (ID 4)
				Si tipoSalaElegida == 4 Entonces
					oro <- oro + 60;
					Escribir "¡Has derrotado al Golem! Bono de elite: ¡Ganaste 60 de oro!";
				SiNo
					oro <- oro + 30;
					Escribir "Has superado el piso! Ganaste 30 de oro.";
				FinSi
				
				OrquestadorReliquias("FIN_SALA", inventarioReliquias, vidaActual, vidaMaxima, danojugador, dummy1, dummy2, dummy3, dummy4, oro);
				Esperar 2.5 Segundos;
				
				// Abrir cofre post-combate
				AbrirCofrePostCombate(inventarioReliquias, totalReliquiasEquipadas, oro, danojugador, vidaActual, vidaMaxima);
			SiNo
				PasoActual <- 9; // Fin por derrota
			FinSi
			
			Limpiar Pantalla;
			
		Fin Mientras
	Hasta Que PasoActual > 8
	
	// Si supero los 8 pisos con vida, inicia el enfrentamiento contra el Jefe Final
	Si vidaActual > 0 Entonces
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir " ¡HAS LLEGADO AL ABISMO DEL JEFE FINAL!  ";
		Escribir "=========================================";
		Escribir "El Dragon Colosal alza el vuelo ante ti...";
		Esperar 3 Segundos;
		
		SalaJefeFinal(vidaActual, vidaMaxima, danojugador, cantidadpociones, inventarioReliquias, totalReliquiasEquipadas, oro);
		
		Limpiar Pantalla;
		Si vidaActual > 0 Entonces
			Escribir "=========================================";
			Escribir " VICTORIA TOTAL! Has derrotado al Dragon.";
			Escribir "=========================================";
		SiNo
			Escribir "=========================================";
			Escribir "  GAME OVER - Caiste ante el Jefe Final. ";
			Escribir "=========================================";
		FinSi
	SiNo
		Escribir "=========================================";
		Escribir "  GAME OVER - Has sido derrotado.";
		Escribir "=========================================";
	FinSi
	
FinAlgoritmo