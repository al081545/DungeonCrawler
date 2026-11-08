SubProceso Sala1
	// Subproceso de ejemplo
FinSubProceso

SubProceso SalaTienda(vidajugador Por Referencia, danojugador Por Referencia, cantidadpociones Por Referencia)
	Definir opciontienda Como Entero;
	
	Repetir
		Limpiar Pantalla;
		Escribir "=========================================";
		Escribir "           TIENDA DEL MERCADER           ";
		Escribir "=========================================";
		Escribir "Tus Pociones actuales: ", cantidadpociones;
		Escribir "Tu Vida actual: ", vidajugador;
		Escribir "Tu Daño actual: ", danojugador;
		Escribir "-----------------------------------------";
		Escribir "1: Comprar 1 Poción extra (Gratis por evento)";
		Escribir "2: Frasco de Vida Máxima (+50 HP) - Requiere 2 pociones";
		Escribir "3: Afilar arma (+10 de daño) - Requiere 2 pociones";
		Escribir "4: Salir de la tienda";
		Escribir "=========================================";
		Escribir "Elige una opción obligatoria:";
		Leer opciontienda;
		
		Segun opciontienda Hacer
			1:
				cantidadpociones <- cantidadpociones + 1;
				Escribir "¡Has obtenido una poción extra!";
				Esperar 1.5 Segundos;
			2:
				Si cantidadpociones >= 2 Entonces
					cantidadpociones <- cantidadpociones - 2;
					vidajugador <- vidajugador + 50;
					Escribir "¡Te bebiste un tónico! Tu vida aumenta.";
				SiNo
					Escribir "¡No tienes suficientes pociones (requieres 2)!";
				FinSi
				Esperar 1.5 Segundos;
			3:
				Si cantidadpociones >= 2 Entonces
					cantidadpociones <- cantidadpociones - 2;
					danojugador <- danojugador + 10;
					Escribir "¡Afilaste tu arma! Tu daño aumenta.";
				SiNo
					Escribir "¡No tienes suficientes pociones (requieres 2)!";
				FinSi
				Esperar 1.5 Segundos;
			4:
				Escribir "Sales de la tienda y continúas tu camino...";
				Esperar 1 Segundos;
			De Otro Modo:
				Escribir "Opción inválida. Inténtalo de nuevo.";
				Esperar 1.5 Segundos;
		FinSegun
	Hasta Que opciontienda == 4
FinSubProceso

SubProceso SalaGenerada1(vidajugador Por Referencia, danojugador Por Valor)
	//pelea contra 2 zombies
	Definir z1, z2, accion Como Entero;
	z1 <- 50;
	z2 <- 50;
	Repetir
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=== SALA 1: DOS ZOMBIES ===";
	        Escribir "HP Jugador: ", vidajugador;
	        
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
	        
	        Escribir "1: Atacar | 2: Defender";
	        Leer accion;
	        Si accion <> 1 Y accion <> 2 Entonces
	            Escribir "Acción inválida. Selecciona 1 o 2.";
	            Esperar 1 Segundos;
	        FinSi
	    Hasta Que accion == 1 O accion == 2
	    
	    Segun accion Hacer
	        1:
	            z1 <- z1 - danojugador;
	            z2 <- z2 - danojugador;
	            Escribir "¡Atacaste a ambos zombis!";
	        2:
	            Escribir "Te pones en guardia.";
	    FinSegun
	    
	    Si z1 > 0 Entonces
	        vidajugador <- vidajugador - 10;
	    FinSi
	    Si z2 > 0 Entonces
	        vidajugador <- vidajugador - 10;
	    FinSi
	    Esperar 1.5 Segundos;
	Hasta Que (z1 <= 0 Y z2 <= 0) O vidajugador <= 0
FinSubProceso

SubProceso SalaGenerada2(vidajugador Por Referencia, danojugador Por Valor)
	//pelea contra esqueleto y zombie
	Definir zombieHP, esqueletoHP, accion Como Entero;
	zombieHP <- 50;
	esqueletoHP <- 70;
	Repetir
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=== SALA 2: ZOMBI Y ESQUELETO ===";
	        Escribir "HP Jugador: ", vidajugador;
	        
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
	        
	        Escribir "1: Atacar | 2: Defender";
	        Leer accion;
	        Si accion <> 1 Y accion <> 2 Entonces
	            Escribir "Acción inválida. Selecciona 1 o 2.";
	            Esperar 1 Segundos;
	        FinSi
	    Hasta Que accion == 1 O accion == 2
	    
	    Segun accion Hacer
	        1:
	            zombieHP <- zombieHP - danojugador;
	            esqueletoHP <- esqueletoHP - danojugador;
	            Escribir "¡Atacaste a los enemigos!";
	        2:
	            Escribir "Te proteges del impacto.";
	    FinSegun
	    
	    Si zombieHP > 0 Entonces
	        vidajugador <- vidajugador - 10;
	    FinSi
	    Si esqueletoHP > 0 Entonces
	        vidajugador <- vidajugador - 15;
	    FinSi
	    Esperar 1.5 Segundos;
	Hasta Que (zombieHP <= 0 Y esqueletoHP <= 0) O vidajugador <= 0
FinSubProceso

SubProceso SalaGenerada3(vidajugador Por Referencia, danojugador Por Valor)
	//pelea contra slime y esqueleto
	Definir slimeHP, esqueletoHP, accion Como Entero;
	slimeHP <- 40;
	esqueletoHP <- 70;
	Repetir
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=== SALA 3: SLIME Y ESQUELETO ===";
	        Escribir "HP Jugador: ", vidajugador;
	        
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
	        
	        Escribir "1: Atacar | 2: Defender";
	        Leer accion;
	        Si accion <> 1 Y accion <> 2 Entonces
	            Escribir "Acción inválida. Selecciona 1 o 2.";
	            Esperar 1 Segundos;
	        FinSi
	    Hasta Que accion == 1 O accion == 2
	    
	    Segun accion Hacer
	        1:
	            slimeHP <- slimeHP - danojugador;
	            esqueletoHP <- esqueletoHP - danojugador;
	            Escribir "¡Atacaste con fuerza!";
	        2:
	            Escribir "Te defiendes.";
	    FinSegun
	    
	    Si slimeHP > 0 Entonces
	        vidajugador <- vidajugador - 5;
	    FinSi
	    Si esqueletoHP > 0 Entonces
	        vidajugador <- vidajugador - 15;
	    FinSi
	    Esperar 1.5 Segundos;
	Hasta Que (slimeHP <= 0 Y esqueletoHP <= 0) O vidajugador <= 0
FinSubProceso

SubProceso SalaGenerada4(vidajugador Por Referencia, danojugador Por Valor)
	//pelea contra golem y zombie
	Definir golemHP, zombieHP, accion Como Entero;
	Definir golemAtaca Como Logico;
	golemHP <- 200;
	zombieHP <- 50;
	golemAtaca <- Falso;
	
	Repetir
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=== SALA 4: GOLEM Y ZOMBI ===";
	        Escribir "HP Jugador: ", vidajugador;
	        
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
		        Escribir "[!] ¡El Golem está listo para atacar este turno!";
	        SiNo
		        Escribir "[*] El Golem está cargando energía...";
	        FinSi
	        
	        Escribir "1: Atacar | 2: Defender";
	        Leer accion;
	        Si accion <> 1 Y accion <> 2 Entonces
	            Escribir "Acción inválida. Selecciona 1 o 2.";
	            Esperar 1 Segundos;
	        FinSi
	    Hasta Que accion == 1 O accion == 2
	    
	    Segun accion Hacer
	        1:
	            golemHP <- golemHP - danojugador;
	            zombieHP <- zombieHP - danojugador;
	            Escribir "¡Impacto directo a los enemigos!";
	        2:
	            Escribir "Te defiendes de los ataques entrantes.";
	    FinSegun
	    
	    Si zombieHP > 0 Entonces
	        vidajugador <- vidajugador - 10;
	    FinSi
	    
	    Si golemHP > 0 Entonces
	        Si golemAtaca Entonces
	            Escribir "¡El Golem desata su ataque masivo de 30 de daño!";
	            vidajugador <- vidajugador - 30;
	            golemAtaca <- Falso;
	        SiNo
	            Escribir "El Golem ruge mientras acumula poder (sin daño este turno).";
	            golemAtaca <- Verdadero;
	        FinSi
	    FinSi
	    
	    Esperar 2 Segundos;
	Hasta Que (golemHP <= 0 Y zombieHP <= 0) O vidajugador <= 0
FinSubProceso

SubProceso SalaGenerada5(vidajugador Por Referencia, danojugador Por Valor)
	//pelea contra 3 slimes
	Definir s1, s2, s3, accion Como Entero;
	s1 <- 40;
	s2 <- 40;
	s3 <- 40;
	Repetir
	    Repetir
	        Limpiar Pantalla;
	        Escribir "=== SALA 5: TRES SLIMES ===";
	        Escribir "HP Jugador: ", vidajugador;
	        
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
	        
	        Escribir "1: Atacar | 2: Defender";
	        Leer accion;
	        Si accion <> 1 Y accion <> 2 Entonces
	            Escribir "Acción inválida. Selecciona 1 o 2.";
	            Esperar 1 Segundos;
	        FinSi
	    Hasta Que accion == 1 O accion == 2
	    
	    Segun accion Hacer
	        1:
	            s1 <- s1 - danojugador;
	            s2 <- s2 - danojugador;
	            s3 <- s3 - danojugador;
	            Escribir "¡Atacaste a los slimes gelatinosos!";
	        2:
	            Escribir "Te proteges.";
	    FinSegun
	    
	    Si s1 > 0 Entonces
		    vidajugador <- vidajugador - 5;
	    FinSi
	    Si s2 > 0 Entonces
		    vidajugador <- vidajugador - 5;
	    FinSi
	    Si s3 > 0 Entonces
		    vidajugador <- vidajugador - 5;
	    FinSi
	    
	    Esperar 1.5 Segundos;
	Hasta Que (s1 <= 0 Y s2 <= 0 Y s3 <= 0) O vidajugador <= 0
FinSubProceso

SubProceso inventario
	Definir itemid Como Caracter;
	Dimensionar itemid(3);
	itemid(1) <- "Bomba de humo";
	itemid(2) <- "Excalibur";
	itemid(3) <- "Contenedor de Vida";
FinSubProceso

Algoritmo DungeonCrawl
	Definir PasoActual, vidajugador, accion, cantidadpociones, opcioncamino, enemigoIzquierda, enemigoDerecha, oro Como Entero;
	Definir ganar, gano Como Logico;
	Definir danojugador Como Entero;
	Dimensionar inventariojugador(3);
	
	// Definir variables iniciales que se modifican durante la partida
	danojugador <- 25;
	PasoActual <- 1;
	vidajugador <- 200;
	cantidadpociones <- 0;
	oro <- 0;
	
	// Aqui empieza el juego
	Escribir "Oprime cualquier tecla para continuar...";
	Esperar Tecla;
	Limpiar Pantalla;
	
	Repetir
		Mientras PasoActual <= 8 Hacer
			
			gano <- Falso;
			
			// Generacion inteligente de rutas: Tienda asegurada en pisos pares (2, 4, 6, 8)
			Si PasoActual MOD 2 == 0 Entonces
				Si Aleatorio(1, 2) == 1 Entonces
					enemigoIzquierda <- 6; // Tienda a la izquierda
					enemigoDerecha <- Aleatorio(1, 5); // Combate a la derecha
				SiNo
					enemigoIzquierda <- Aleatorio(1, 5); // Combate a la izquierda
					enemigoDerecha <- 6; // Tienda a la derecha
				FinSi
			SiNo
				// En pisos impares, rutas de combate aleatorias
				enemigoIzquierda <- Aleatorio(1, 5);
				enemigoDerecha <- Aleatorio(1, 5);
				Mientras enemigoDerecha == enemigoIzquierda Hacer
					enemigoDerecha <- Aleatorio(1, 5);
				FinMientras
			FinSi
			
			// Validar seleccion de camino segura
			Repetir
				Limpiar Pantalla;
				Escribir "=========================================";
				Escribir "          MAPA DE LA MAZMORRA          ";
				Escribir "=========================================";
				Escribir "    [ Piso ", PasoActual, " / 8 ] | Oro: ", oro;
				Escribir "                                         ";
				Escribir "           ( Tu posicion actual )        ";
				Escribir "                  [ X ]                  ";
				Escribir "                /       \              ";
				Escribir "     [Ruta Izquierda]   [Ruta Derecha]   ";
				
				Si enemigoIzquierda == 6 Entonces
					Escribir " 1. Tienda del Mercader";
				SiNo
					Escribir " 1. Sala Tipo ", enemigoIzquierda;
				FinSi
				
				Si enemigoDerecha == 6 Entonces
					Escribir " 2. Tienda del Mercader";
				SiNo
					Escribir " 2. Sala Tipo ", enemigoDerecha;
				FinSi
				
				Escribir "=========================================";
				Escribir Sin Saltar "      Elige tu camino (1 o 2):";
				Leer opcioncamino;
				
				Si opcioncamino <> 1 Y opcioncamino <> 2 Entonces
					Escribir "Camino no valido. Elige 1 o 2.";
					Esperar 1 Segundos;
				FinSi
			Hasta Que opcioncamino == 1 O opcioncamino == 2
			
			// Ejecutar subproceso segun el camino seleccionado
			Segun opcioncamino Hacer
				1: 
					Segun enemigoIzquierda Hacer
						1: 
							SalaGenerada1(vidajugador, danojugador);
						2: 
							SalaGenerada2(vidajugador, danojugador);
						3: 
							SalaGenerada3(vidajugador, danojugador);
						4: 
							SalaGenerada4(vidajugador, danojugador);
						5: 
							SalaGenerada5(vidajugador, danojugador);
						6: 
							SalaTienda(vidajugador, danojugador, cantidadpociones);
					FinSegun
				2: 
					Segun enemigoDerecha Hacer
						
						1: 
							SalaGenerada1(vidajugador, danojugador);
						2: 
							SalaGenerada2(vidajugador, danojugador);
						3: 
							SalaGenerada3(vidajugador, danojugador);
						4: 
							SalaGenerada4(vidajugador, danojugador);
						5: 
							SalaGenerada5(vidajugador, danojugador);
						6: 
							SalaTienda(vidajugador, danojugador, cantidadpociones);
					FinSegun
			FinSegun
			
			// Finaliza evento / combate
			Limpiar Pantalla;
			Escribir "SECCION COMPLETADA";
			Esperar 1 Segundos;
			
			// Analisis de vida del jugador
			Si vidajugador > 0 Entonces
				PasoActual <- PasoActual + 1;
				gano <- Verdadero;
				// Recompensa de oro por superar un piso con exito
				oro <- oro + 30;
			SiNo
				PasoActual <- 9; // Fuera del rango <= 8 para terminar
			FinSi
			
			// Mensaje tras superar sala
			Si vidajugador > 0 Y gano Entonces
				Escribir "Has superado el piso! Ganaste 30 de oro. Presiona una tecla...";
				Esperar Tecla;
			FinSi
			Limpiar Pantalla;
			
		Fin Mientras
	Hasta Que PasoActual > 8
	
	Si vidajugador > 0 Entonces
		Escribir "=========================================";
		Escribir "  VICTORIA! Has conquistado la mazmorra.";
		Escribir "=========================================";
	SiNo
		Escribir "=========================================";
		Escribir "  GAME OVER - Has sido derrotado.";
		Escribir "=========================================";
	FinSi
	
FinAlgoritmo