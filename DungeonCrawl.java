import java.util.Random;
import java.util.Scanner;

public class DungeonCrawl {

    // Clase para manejar las variables "Por Referencia" de PSeInt
    static class EstadoJuego {
        int vidaActual = 200;
        int vidaMaxima = 200;
        int danoJugador = 25;
        int cantidadPociones = 0;
        int oro = 0;
        String[] inventarioReliquias = new String[6]; // Slots del 1 al 5
        int totalReliquiasEquipadas = 0;

        // Variables de retorno temporal para el Orquestador
        int danoFinal = 0;
        int danoEntrante = 0;
        int danoReflejado = 0;
        int danoAreaTurno = 0;

        public EstadoJuego() {
            for (int i = 1; i <= 5; i++) {
                inventarioReliquias[i] = "Vacio";
            }
        }
    }

    static Scanner scanner = new Scanner(System.in);
    static Random random = new Random();

    // -----------------------------------------------------------------
    // UTILIDADES DE CONSOLA (Equivalentes a PSeInt)
    // -----------------------------------------------------------------
    public static void limpiarPantalla() {
        try {
            if (System.getProperty("os.name").contains("Windows")) {
                new ProcessBuilder("cmd", "/c", "cls").inheritIO().start().waitFor();
            } else {
                System.out.print("\033[H\033[2J");
                System.out.flush();
            }
        } catch (Exception e) {
            for (int i = 0; i < 40; i++) System.out.println();
        }
    }

    public static void esperarSegundos(double segundos) {
        try {
            Thread.sleep((long) (segundos * 1000));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    public static void esperarTecla() {
        scanner.nextLine();
    }

    public static int aleatorio(int min, int max) {
        return random.nextInt((max - min) + 1) + min;
    }

    public static String leerOpcion() {
        return scanner.nextLine().trim();
    }

    // -----------------------------------------------------------------
    // BASE DE DATOS DE RELIQUIAS Y DESCRIPCIONES CORTAS
    // -----------------------------------------------------------------
    public static String[] obtenerDetallesReliquia(int id) {
        switch (id) {
            case 1: return new String[]{"Anillo de Defensa", "+25 Vida Maxima y cura +25 HP"};
            case 2: return new String[]{"Anillo Critico", "25% probabilidad de golpe critico (x2)"};
            case 3: return new String[]{"Collar de Espinas", "Devuelve 10 de dano al atacante"};
            case 4: return new String[]{"Monedero", "+15 monedas extra al superar salas"};
            case 5: return new String[]{"Mazo de Obsidiana", "+12 de dano fisico permanente"};
            case 6: return new String[]{"Excalibur", "+10 de dano fisico legendario"};
            case 7: return new String[]{"Daga Venenosa", "+6 de dano venenoso por impacto"};
            case 8: return new String[]{"Bomba de Humo", "20% probabilidad de esquivar ataques"};
            case 9: return new String[]{"Daga Vampirica", "Cura el 20% del dano infligido"};
            case 10: return new String[]{"Libro Volcanico", "8 de dano de fuego en area por turno"};
            default: return new String[]{"Vacio", "Sin objeto equipado"};
        }
    }

    // -----------------------------------------------------------------
    // PISTAS AMBIENTALES PARA LAS SALAS DEL MAPA
    // -----------------------------------------------------------------
    public static String obtenerPistaSala(int tipoSala) {
        switch (tipoSala) {
            case 1: return "Se escuchan grunidos y un fuerte olor a muerto...";
            case 2: return "Pasos arrastrados y el crujir de huesos viejos...";
            case 3: return "Un burbujeo viscoso seguido del choque de huesos...";
            case 4: return "Tienes un mal presentimiento... no creo que sea buena idea.";
            case 5: return "El suelo vibra con un chapoteo gelatinoso y acido...";
            default: return "Un pasillo oscuro y silencioso...";
        }
    }

    // -----------------------------------------------------------------
    // FUNCION AUXILIAR: Verifica si el jugador tiene una reliquia equipada
    // -----------------------------------------------------------------
    public static boolean tieneReliquia(EstadoJuego estado, String nombreBuscado) {
        for (int i = 1; i <= 5; i++) {
            if (estado.inventarioReliquias[i].equals(nombreBuscado)) {
                return true;
            }
        }
        return false;
    }

    // -----------------------------------------------------------------
    // ORQUESTADOR DE RELIQUIAS
    // -----------------------------------------------------------------
    public static void orquestadorReliquias(String fase, EstadoJuego estado) {
        estado.danoFinal = estado.danoJugador;
        estado.danoReflejado = 0;
        estado.danoAreaTurno = 0;

        // FASE 1: INICIO DEL TURNO
        if (fase.equals("INICIO_TURNO")) {
            if (tieneReliquia(estado, "Libro Volcanico")) {
                estado.danoAreaTurno = 8;
                System.out.println("[Reliquia: Libro Volcanico] Las llamas queman a todos los enemigos (-8 HP).");
            }
        }

        // FASE 2: AL ATACAR
        if (fase.equals("AL_ATACAR")) {
            if (tieneReliquia(estado, "Anillo Critico")) {
                if (aleatorio(1, 100) <= 25) {
                    estado.danoFinal *= 2;
                    System.out.println("[Reliquia: Anillo Critico] ¡GOLPE CRITICO! Dano duplicado a " + estado.danoFinal + ".");
                }
            }

            if (tieneReliquia(estado, "Daga Venenosa")) {
                estado.danoFinal += 6;
                System.out.println("[Reliquia: Daga Venenosa] Veneno aplicado (+6 de dano extra).");
            }

            if (tieneReliquia(estado, "Daga Vampirica")) {
                int curacionVampirica = (int) (estado.danoFinal * 0.20);
                if (curacionVampirica < 1) {
                    curacionVampirica = 1;
                }
                if (estado.vidaActual < estado.vidaMaxima) {
                    estado.vidaActual += curacionVampirica;
                    if (estado.vidaActual > estado.vidaMaxima) {
                        estado.vidaActual = estado.vidaMaxima;
                    }
                    System.out.println("[Reliquia: Daga Vampirica] Absorbes " + curacionVampirica + " HP del enemigo.");
                }
            }
        }

        // FASE 3: AL RECIBIR DANO
        if (fase.equals("AL_RECIBIR_DANO")) {
            if (tieneReliquia(estado, "Bomba de Humo")) {
                if (aleatorio(1, 100) <= 20) {
                    estado.danoEntrante = 0;
                    System.out.println("[Reliquia: Bomba de Humo] ¡Desapareces en el humo y esquivas el ataque!");
                }
            }

            if (tieneReliquia(estado, "Collar de Espinas")) {
                estado.danoReflejado = 10;
                System.out.println("[Reliquia: Collar de Espinas] Las espinas devuelven 10 de dano al atacante.");
            }
        }

        // FASE 4: FIN DE SALA
        if (fase.equals("FIN_SALA")) {
            if (tieneReliquia(estado, "Monedero")) {
                estado.oro += 15;
                System.out.println("[Reliquia: Monedero] ¡Encuentras 15 monedas de oro adicionales!");
            }
        }
    }

    // -----------------------------------------------------------------
    // INTERFAZ DE INVENTARIO EN COMBATE
    // -----------------------------------------------------------------
    public static void verInventarioCombate(EstadoJuego estado) {
        String opcionInv;

        do {
            limpiarPantalla();
            System.out.println("=========================================");
            System.out.println("          INVENTARIO DEL JUGADOR         ");
            System.out.println("=========================================");
            System.out.println("Vida: " + estado.vidaActual + " / " + estado.vidaMaxima);
            System.out.println("Dano base actual: " + estado.danoJugador);
            System.out.println("Oro disponible: " + estado.oro + " monedas");
            System.out.println("Pociones disponibles: " + estado.cantidadPociones);
            System.out.println("-----------------------------------------");
            System.out.println("SLOTS DE RELIQUIAS PASIVAS (" + estado.totalReliquiasEquipadas + " / 5):");

            for (int i = 1; i <= 5; i++) {
                if (i <= estado.totalReliquiasEquipadas) {
                    System.out.println("  [Slot " + i + "] -> " + estado.inventarioReliquias[i]);
                } else {
                    System.out.println("  [Slot " + i + "] -> [ Vacio ]");
                }
            }

            System.out.println("=========================================");
            System.out.println(" [1] Usar una Pocion (+50 HP)");
            System.out.println(" [2] Salir del Inventario (Volver al combate)");
            System.out.println("=========================================");
            System.out.print("Elige una opcion: ");
            opcionInv = leerOpcion();

            if (opcionInv.equals("1")) {
                if (estado.cantidadPociones > 0) {
                    if (estado.vidaActual < estado.vidaMaxima) {
                        estado.cantidadPociones--;
                        estado.vidaActual += 50;
                        if (estado.vidaActual > estado.vidaMaxima) {
                            estado.vidaActual = estado.vidaMaxima;
                        }
                        System.out.println("¡Te has tomado una pocion! Recuperas salud.");
                        esperarSegundos(2.5);
                    } else {
                        System.out.println("¡Tienes la vida a tope!");
                        esperarSegundos(2.5);
                    }
                } else {
                    System.out.println("¡No tienes pociones disponibles!");
                    esperarSegundos(2.5);
                }
            } else if (!opcionInv.equals("2")) {
                System.out.println("Opcion invalida. Elige 1 o 2.");
                esperarSegundos(2);
            }
        } while (!opcionInv.equals("2"));
    }

    // -----------------------------------------------------------------
    // SISTEMA DE COFRE POST-COMBATE
    // -----------------------------------------------------------------
    public static void abrirCofrePostCombate(EstadoJuego estado) {
        int id1, id2;
        String[] det1, det2;
        String opcionCofre, reliquiaElegida, reliquiaDescartada, opcionReemplazo;
        boolean esRepetida;

        // Sortear Reliquia 1
        do {
            id1 = aleatorio(1, 10);
            det1 = obtenerDetallesReliquia(id1);
            esRepetida = false;
            for (int i = 1; i <= estado.totalReliquiasEquipadas; i++) {
                if (estado.inventarioReliquias[i].equals(det1[0])) {
                    esRepetida = true;
                }
            }
        } while (esRepetida);

        // Sortear Reliquia 2
        do {
            id2 = aleatorio(1, 10);
            det2 = obtenerDetallesReliquia(id2);
            esRepetida = false;
            if (id2 == id1) {
                esRepetida = true;
            } else {
                for (int i = 1; i <= estado.totalReliquiasEquipadas; i++) {
                    if (estado.inventarioReliquias[i].equals(det2[0])) {
                        esRepetida = true;
                    }
                }
            }
        } while (esRepetida);

        // Menu principal del cofre
        do {
            limpiarPantalla();
            System.out.println("=========================================");
            System.out.println("            ¡SALA SUPERADA!             ");
            System.out.println("           ¡ABRISTE UN COFRE!           ");
            System.out.println("=========================================");
            System.out.println(" Elige una reliquia para tu inventario:  \n");
            System.out.println(" [1] " + det1[0]);
            System.out.println("     - " + det1[1] + "\n");
            System.out.println(" [2] " + det2[0]);
            System.out.println("     - " + det2[1] + "\n");
            System.out.println(" [3] Rechazar ambas (Recibir 30 de Oro)");
            System.out.println("=========================================");
            System.out.println(" Espacios ocupados: [ " + estado.totalReliquiasEquipadas + " / 5 ]");
            System.out.println("=========================================");
            System.out.print(" Elige tu opcion (1, 2 o 3): ");
            opcionCofre = leerOpcion();

            if (!opcionCofre.equals("1") && !opcionCofre.equals("2") && !opcionCofre.equals("3")) {
                System.out.println("Entrada no valida. Elige 1, 2 o 3.");
                esperarSegundos(2);
            }
        } while (!opcionCofre.equals("1") && !opcionCofre.equals("2") && !opcionCofre.equals("3"));

        if (opcionCofre.equals("1") || opcionCofre.equals("2")) {
            reliquiaElegida = opcionCofre.equals("1") ? det1[0] : det2[0];

            if (estado.totalReliquiasEquipadas < 5) {
                estado.totalReliquiasEquipadas++;
                estado.inventarioReliquias[estado.totalReliquiasEquipadas] = reliquiaElegida;
                System.out.println("¡Has obtenido y equipado: " + reliquiaElegida + "!");

                if (reliquiaElegida.equals("Mazo de Obsidiana")) {
                    estado.danoJugador += 12;
                } else if (reliquiaElegida.equals("Excalibur")) {
                    estado.danoJugador += 10;
                } else if (reliquiaElegida.equals("Anillo de Defensa")) {
                    estado.vidaMaxima += 25;
                    estado.vidaActual += 25;
                }
                esperarSegundos(3);
            } else {
                do {
                    limpiarPantalla();
                    System.out.println("=========================================");
                    System.out.println("      ¡INVENTARIO LLENO (5 / 5)!         ");
                    System.out.println("=========================================");
                    System.out.println(" Intentas equipar: " + reliquiaElegida);
                    System.out.println(" Selecciona que slot deseas reemplazar:");
                    System.out.println("-----------------------------------------");
                    for (int i = 1; i <= 5; i++) {
                        System.out.println(" [" + i + "] Reemplazar a: " + estado.inventarioReliquias[i]);
                    }
                    System.out.println(" [6] Arrepentirse y llevarse 30 de oro");
                    System.out.println("=========================================");
                    System.out.print("Elige una opcion (1 a 6): ");
                    opcionReemplazo = leerOpcion();

                    if (!opcionReemplazo.matches("[1-6]")) {
                        System.out.println("Entrada no valida. Elige del 1 al 6.");
                        esperarSegundos(2);
                    }
                } while (!opcionReemplazo.matches("[1-6]"));

                if (!opcionReemplazo.equals("6")) {
                    int slotAElegir = Integer.parseInt(opcionReemplazo);
                    reliquiaDescartada = estado.inventarioReliquias[slotAElegir];

                    if (reliquiaDescartada.equals("Mazo de Obsidiana")) {
                        estado.danoJugador -= 12;
                    } else if (reliquiaDescartada.equals("Excalibur")) {
                        estado.danoJugador -= 10;
                    } else if (reliquiaDescartada.equals("Anillo de Defensa")) {
                        estado.vidaMaxima -= 25;
                        if (estado.vidaActual > estado.vidaMaxima) {
                            estado.vidaActual = estado.vidaMaxima;
                        }
                    }

                    System.out.println("¡Has descartado a " + reliquiaDescartada + " y equipado " + reliquiaElegida + "!");
                    estado.inventarioReliquias[slotAElegir] = reliquiaElegida;

                    if (reliquiaElegida.equals("Mazo de Obsidiana")) {
                        estado.danoJugador += 12;
                    } else if (reliquiaElegida.equals("Excalibur")) {
                        estado.danoJugador += 10;
                    } else if (reliquiaElegida.equals("Anillo de Defensa")) {
                        estado.vidaMaxima += 25;
                        estado.vidaActual += 25;
                    }
                    esperarSegundos(3);
                } else {
                    estado.oro += 30;
                    System.out.println("Has decidido conservar tus reliquias. Obtienes 30 de oro.");
                    esperarSegundos(2.5);
                }
            }
        } else {
            estado.oro += 30;
            System.out.println("Has rechazado las reliquias. Obtienes 30 de oro.");
            esperarSegundos(2.5);
        }
        limpiarPantalla();
    }

    // -----------------------------------------------------------------
    // MAPA COMPACTO DE LA MAZMORRA
    // -----------------------------------------------------------------
    public static void mostrarMapaCompacto(int pasoActual, int oro, int enemigoIzquierda, int enemigoDerecha, int ultimaSalaSuperada) {
        String pistaIzquierda = obtenerPistaSala(enemigoIzquierda);
        String pistaDerecha = obtenerPistaSala(enemigoDerecha);

        limpiarPantalla();
        System.out.println("===================================================================");
        System.out.println("                       MAPA DE LA MAZMORRA                         ");
        System.out.println("===================================================================");

        if (pasoActual > 1) {
            System.out.println(" [Rastro] Piso " + (pasoActual - 1) + " (Sala " + ultimaSalaSuperada + ") -> Piso " + pasoActual + " (Actual)");
        } else {
            System.out.println(" [Inicio de aventura] -> Piso 1 (Actual)");
        }

        System.out.println(" Oro actual: " + oro + " monedas");
        System.out.println("-------------------------------------------------------------------");
        System.out.println("                         ELIGE TU CAMINO:                          \n");
        System.out.println("   [1] -> " + pistaIzquierda);
        System.out.println("   [2] -> " + pistaDerecha);
        System.out.println("   [3] -> Visitar la Tienda del Mercader");
        System.out.println("===================================================================");
    }

    // -----------------------------------------------------------------
    // TIENDA DEL MERCADER
    // -----------------------------------------------------------------
    public static void salaTienda(EstadoJuego estado) {
        String opcionTienda;

        do {
            limpiarPantalla();
            System.out.println("=========================================");
            System.out.println("           TIENDA DEL MERCADER           ");
            System.out.println("=========================================");
            System.out.println("Tu Oro disponible: " + estado.oro + " monedas");
            System.out.println("Tu Vida: " + estado.vidaActual + " / " + estado.vidaMaxima);
            System.out.println("Tu Dano actual: " + estado.danoJugador);
            System.out.println("Tus Pociones: " + estado.cantidadPociones);
            System.out.println("-----------------------------------------");
            System.out.println(" [1] Comprar 1 Pocion extra       (Costo: 20 oro)");
            System.out.println(" [2] Frasco de Vida Maxima (+50 HP) (Costo: 50 oro)");
            System.out.println(" [3] Afilar arma (+10 de dano)      (Costo: 40 oro)");
            System.out.println(" [4] Salir de la tienda");
            System.out.println("=========================================");
            System.out.print("Elige una opcion: ");
            opcionTienda = leerOpcion();

            switch (opcionTienda) {
                case "1":
                    if (estado.oro >= 20) {
                        estado.oro -= 20;
                        estado.cantidadPociones++;
                        System.out.println("¡Has comprado 1 pocion extra!");
                    } else {
                        System.out.println("¡No tienes suficiente oro (requieres 20)!");
                    }
                    esperarSegundos(2.5);
                    break;
                case "2":
                    if (estado.oro >= 50) {
                        estado.oro -= 50;
                        estado.vidaMaxima += 50;
                        estado.vidaActual += 50;
                        System.out.println("¡Te bebiste un tonico supremo! Tu vida maxima aumenta.");
                    } else {
                        System.out.println("¡No tienes suficiente oro (requieres 50)!");
                    }
                    esperarSegundos(2.5);
                    break;
                case "3":
                    if (estado.oro >= 40) {
                        estado.oro -= 40;
                        estado.danoJugador += 10;
                        System.out.println("¡Afilaste tu arma! Tu dano aumenta.");
                    } else {
                        System.out.println("¡No tienes suficiente oro (requieres 40)!");
                    }
                    esperarSegundos(2.5);
                    break;
                case "4":
                    System.out.println("Sales de la tienda y continuas tu camino...");
                    esperarSegundos(2);
                    break;
                default:
                    System.out.println("Opcion invalida. Intentalo de nuevo.");
                    esperarSegundos(2.5);
                    break;
            }
        } while (!opcionTienda.equals("4"));
    }

    // -----------------------------------------------------------------
    // SUBPROCESOS DE COMBATE
    // -----------------------------------------------------------------

    // --- SALA 1: DOS ZOMBIES ---
    public static void salaGenerada1(EstadoJuego estado) {
        int z1 = 50, z2 = 50;
        String accion;
        boolean defendiendo;

        do {
            defendiendo = false;
            do {
                limpiarPantalla();
                System.out.println("=== SALA 1: DOS ZOMBIES ===");
                System.out.println("HP Jugador: " + estado.vidaActual + " / " + estado.vidaMaxima);
                System.out.println(z1 <= 0 ? "Zombi 1 HP: || M U E R T O ||" : "Zombi 1 HP: " + z1);
                System.out.println(z2 <= 0 ? "Zombi 2 HP: || M U E R T O ||" : "Zombi 2 HP: " + z2);
                System.out.println("-----------------------------------------");
                System.out.println("1: Atacar | 2: Defender | 3: Inventario");
                accion = leerOpcion();

                if (accion.equals("3")) {
                    verInventarioCombate(estado);
                    accion = "0";
                } else if (!accion.equals("1") && !accion.equals("2")) {
                    System.out.println("Accion invalida. Selecciona 1, 2 o 3.");
                    esperarSegundos(2);
                }
            } while (!accion.equals("1") && !accion.equals("2"));

            limpiarPantalla();
            System.out.println("=========================================");
            System.out.println("           ACCION DEL TURNO              ");
            System.out.println("=========================================");

            orquestadorReliquias("INICIO_TURNO", estado);
            if (estado.danoAreaTurno > 0) {
                if (z1 > 0) z1 -= estado.danoAreaTurno;
                if (z2 > 0) z2 -= estado.danoAreaTurno;
            }

            if (accion.equals("1")) {
                if (z1 > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    z1 -= estado.danoFinal;
                    System.out.println("-> Atacaste al Zombi 1 causando " + estado.danoFinal + " de dano.");
                }
                if (z2 > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    z2 -= estado.danoFinal;
                    System.out.println("-> Atacaste al Zombi 2 causando " + estado.danoFinal + " de dano.");
                }
            } else {
                defendiendo = true;
                System.out.println("-> Te pones en guardia. El dano recibido se reduce en un 50%.");
            }

            System.out.println("-----------------------------------------");

            if (z1 > 0) {
                estado.danoEntrante = defendiendo ? 5 : 10;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- El Zombi 1 te ataca e inflige " + estado.danoEntrante + " de dano.");
                if (estado.danoReflejado > 0) z1 -= estado.danoReflejado;
            }
            if (z2 > 0) {
                estado.danoEntrante = defendiendo ? 5 : 10;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- El Zombi 2 te ataca e inflige " + estado.danoEntrante + " de dano.");
                if (estado.danoReflejado > 0) z2 -= estado.danoReflejado;
            }

            System.out.println("=========================================");
            System.out.println("Presiona ENTER para continuar...");
            esperarTecla();

        } while (!((z1 <= 0 && z2 <= 0) || estado.vidaActual <= 0));
    }

    // --- SALA 2: ZOMBI Y ESQUELETO ---
    public static void salaGenerada2(EstadoJuego estado) {
        int zombieHP = 50, esqueletoHP = 70;
        String accion;
        boolean defendiendo;

        do {
            defendiendo = false;
            do {
                limpiarPantalla();
                System.out.println("=== SALA 2: ZOMBI Y ESQUELETO ===");
                System.out.println("HP Jugador: " + estado.vidaActual + " / " + estado.vidaMaxima);
                System.out.println(zombieHP <= 0 ? "Zombi HP: || M U E R T O ||" : "Zombi HP: " + zombieHP);
                System.out.println(esqueletoHP <= 0 ? "Esqueleto HP: || M U E R T O ||" : "Esqueleto HP: " + esqueletoHP);
                System.out.println("-----------------------------------------");
                System.out.println("1: Atacar | 2: Defender | 3: Inventario");
                accion = leerOpcion();

                if (accion.equals("3")) {
                    verInventarioCombate(estado);
                    accion = "0";
                } else if (!accion.equals("1") && !accion.equals("2")) {
                    System.out.println("Accion invalida. Selecciona 1, 2 o 3.");
                    esperarSegundos(2);
                }
            } while (!accion.equals("1") && !accion.equals("2"));

            limpiarPantalla();
            System.out.println("=========================================");
            System.out.println("           ACCION DEL TURNO              ");
            System.out.println("=========================================");

            orquestadorReliquias("INICIO_TURNO", estado);
            if (estado.danoAreaTurno > 0) {
                if (zombieHP > 0) zombieHP -= estado.danoAreaTurno;
                if (esqueletoHP > 0) esqueletoHP -= estado.danoAreaTurno;
            }

            if (accion.equals("1")) {
                if (zombieHP > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    zombieHP -= estado.danoFinal;
                    System.out.println("-> Atacaste al Zombi causando " + estado.danoFinal + " de dano.");
                }
                if (esqueletoHP > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    esqueletoHP -= estado.danoFinal;
                    System.out.println("-> Atacaste al Esqueleto causando " + estado.danoFinal + " de dano.");
                }
            } else {
                defendiendo = true;
                System.out.println("-> Te proteges del impacto. El dano recibido se reduce en un 50%.");
            }

            System.out.println("-----------------------------------------");

            if (zombieHP > 0) {
                estado.danoEntrante = defendiendo ? 5 : 10;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- El Zombi te ataca e inflige " + estado.danoEntrante + " de dano.");
                if (estado.danoReflejado > 0) zombieHP -= estado.danoReflejado;
            }
            if (esqueletoHP > 0) {
                estado.danoEntrante = defendiendo ? 7 : 15;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- El Esqueleto te ataca e inflige " + estado.danoEntrante + " de dano.");
                if (estado.danoReflejado > 0) esqueletoHP -= estado.danoReflejado;
            }

            System.out.println("=========================================");
            System.out.println("Presiona ENTER para continuar...");
            esperarTecla();

        } while (!((zombieHP <= 0 && esqueletoHP <= 0) || estado.vidaActual <= 0));
    }

    // --- SALA 3: SLIME Y ESQUELETO ---
    public static void salaGenerada3(EstadoJuego estado) {
        int slimeHP = 40, esqueletoHP = 70;
        String accion;
        boolean defendiendo;

        do {
            defendiendo = false;
            do {
                limpiarPantalla();
                System.out.println("=== SALA 3: SLIME Y ESQUELETO ===");
                System.out.println("HP Jugador: " + estado.vidaActual + " / " + estado.vidaMaxima);
                System.out.println(slimeHP <= 0 ? "Slime HP: || M U E R T O ||" : "Slime HP: " + slimeHP);
                System.out.println(esqueletoHP <= 0 ? "Esqueleto HP: || M U E R T O ||" : "Esqueleto HP: " + esqueletoHP);
                System.out.println("-----------------------------------------");
                System.out.println("1: Atacar | 2: Defender | 3: Inventario");
                accion = leerOpcion();

                if (accion.equals("3")) {
                    verInventarioCombate(estado);
                    accion = "0";
                } else if (!accion.equals("1") && !accion.equals("2")) {
                    System.out.println("Accion invalida. Selecciona 1, 2 o 3.");
                    esperarSegundos(2);
                }
            } while (!accion.equals("1") && !accion.equals("2"));

            limpiarPantalla();
            System.out.println("=========================================");
            System.out.println("           ACCION DEL TURNO              ");
            System.out.println("=========================================");

            orquestadorReliquias("INICIO_TURNO", estado);
            if (estado.danoAreaTurno > 0) {
                if (slimeHP > 0) slimeHP -= estado.danoAreaTurno;
                if (esqueletoHP > 0) esqueletoHP -= estado.danoAreaTurno;
            }

            if (accion.equals("1")) {
                if (slimeHP > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    slimeHP -= estado.danoFinal;
                    System.out.println("-> Atacaste al Slime causando " + estado.danoFinal + " de dano.");
                }
                if (esqueletoHP > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    esqueletoHP -= estado.danoFinal;
                    System.out.println("-> Atacaste al Esqueleto causando " + estado.danoFinal + " de dano.");
                }
            } else {
                defendiendo = true;
                System.out.println("-> Te defiendes. El dano recibido se reduce en un 50%.");
            }

            System.out.println("-----------------------------------------");

            if (slimeHP > 0) {
                estado.danoEntrante = defendiendo ? 2 : 5;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- El Slime te ataca e inflige " + estado.danoEntrante + " de dano.");
                if (estado.danoReflejado > 0) slimeHP -= estado.danoReflejado;
            }
            if (esqueletoHP > 0) {
                estado.danoEntrante = defendiendo ? 7 : 15;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- El Esqueleto te ataca e inflige " + estado.danoEntrante + " de dano.");
                if (estado.danoReflejado > 0) esqueletoHP -= estado.danoReflejado;
            }

            System.out.println("=========================================");
            System.out.println("Presiona ENTER para continuar...");
            esperarTecla();

        } while (!((slimeHP <= 0 && esqueletoHP <= 0) || estado.vidaActual <= 0));
    }

    // --- SALA 4: GOLEM Y ZOMBI ---
    public static void salaGenerada4(EstadoJuego estado) {
        int golemHP = 200, zombieHP = 50;
        String accion;
        boolean golemAtaca = false, defendiendo;

        do {
            defendiendo = false;
            do {
                limpiarPantalla();
                System.out.println("=== SALA 4: GOLEM Y ZOMBI ===");
                System.out.println("HP Jugador: " + estado.vidaActual + " / " + estado.vidaMaxima);
                System.out.println(golemHP <= 0 ? "Golem HP: || M U E R T O ||" : "Golem HP: " + golemHP);
                System.out.println(zombieHP <= 0 ? "Zombi HP: || M U E R T O ||" : "Zombi HP: " + zombieHP);

                if (golemAtaca) {
                    System.out.println("[!] ¡El Golem esta listo para atacar este turno!");
                } else {
                    System.out.println("[*] El Golem esta cargando energia...");
                }

                System.out.println("-----------------------------------------");
                System.out.println("1: Atacar | 2: Defender | 3: Inventario");
                accion = leerOpcion();

                if (accion.equals("3")) {
                    verInventarioCombate(estado);
                    accion = "0";
                } else if (!accion.equals("1") && !accion.equals("2")) {
                    System.out.println("Accion invalida. Selecciona 1, 2 o 3.");
                    esperarSegundos(2);
                }
            } while (!accion.equals("1") && !accion.equals("2"));

            limpiarPantalla();
            System.out.println("=========================================");
            System.out.println("           ACCION DEL TURNO              ");
            System.out.println("=========================================");

            orquestadorReliquias("INICIO_TURNO", estado);
            if (estado.danoAreaTurno > 0) {
                if (golemHP > 0) golemHP -= estado.danoAreaTurno;
                if (zombieHP > 0) zombieHP -= estado.danoAreaTurno;
            }

            if (accion.equals("1")) {
                if (golemHP > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    golemHP -= estado.danoFinal;
                    System.out.println("-> Atacaste al Golem causando " + estado.danoFinal + " de dano.");
                }
                if (zombieHP > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    zombieHP -= estado.danoFinal;
                    System.out.println("-> Atacaste al Zombi causando " + estado.danoFinal + " de dano.");
                }
            } else {
                defendiendo = true;
                System.out.println("-> Te defiendes de los ataques entrantes. El dano recibido se reduce en un 50%.");
            }

            System.out.println("-----------------------------------------");

            if (zombieHP > 0) {
                estado.danoEntrante = defendiendo ? 5 : 10;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- El Zombi te ataca e inflige " + estado.danoEntrante + " de dano.");
                if (estado.danoReflejado > 0) zombieHP -= estado.danoReflejado;
            }

            if (golemHP > 0) {
                if (golemAtaca) {
                    estado.danoEntrante = defendiendo ? 15 : 30;
                    orquestadorReliquias("AL_RECIBIR_DANO", estado);
                    estado.vidaActual -= estado.danoEntrante;
                    System.out.println("<- ¡El Golem desata su ataque masivo e inflige " + estado.danoEntrante + " de dano!");
                    if (estado.danoReflejado > 0) golemHP -= estado.danoReflejado;
                    golemAtaca = false;
                } else {
                    System.out.println("<- El Golem ruge acumulando poder (sin dano este turno).");
                    golemAtaca = true;
                }
            }

            System.out.println("=========================================");
            System.out.println("Presiona ENTER para continuar...");
            esperarTecla();

        } while (!((golemHP <= 0 && zombieHP <= 0) || estado.vidaActual <= 0));
    }

    // --- SALA 5: TRES SLIMES ---
    public static void salaGenerada5(EstadoJuego estado) {
        int s1 = 40, s2 = 40, s3 = 40;
        String accion;
        boolean defendiendo;

        do {
            defendiendo = false;
            do {
                limpiarPantalla();
                System.out.println("=== SALA 5: TRES SLIMES ===");
                System.out.println("HP Jugador: " + estado.vidaActual + " / " + estado.vidaMaxima);
                System.out.println(s1 <= 0 ? "Slime 1: || M U E R T O ||" : "Slime 1: " + s1);
                System.out.println(s2 <= 0 ? "Slime 2: || M U E R T O ||" : "Slime 2: " + s2);
                System.out.println(s3 <= 0 ? "Slime 3: || M U E R T O ||" : "Slime 3: " + s3);
                System.out.println("-----------------------------------------");
                System.out.println("1: Atacar | 2: Defender | 3: Inventario");
                accion = leerOpcion();

                if (accion.equals("3")) {
                    verInventarioCombate(estado);
                    accion = "0";
                } else if (!accion.equals("1") && !accion.equals("2")) {
                    System.out.println("Accion invalida. Selecciona 1, 2 o 3.");
                    esperarSegundos(2);
                }
            } while (!accion.equals("1") && !accion.equals("2"));

            limpiarPantalla();
            System.out.println("=========================================");
            System.out.println("           ACCION DEL TURNO              ");
            System.out.println("=========================================");

            orquestadorReliquias("INICIO_TURNO", estado);
            if (estado.danoAreaTurno > 0) {
                if (s1 > 0) s1 -= estado.danoAreaTurno;
                if (s2 > 0) s2 -= estado.danoAreaTurno;
                if (s3 > 0) s3 -= estado.danoAreaTurno;
            }

            if (accion.equals("1")) {
                if (s1 > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    s1 -= estado.danoFinal;
                    System.out.println("-> Atacaste al Slime 1 causando " + estado.danoFinal + " de dano.");
                }
                if (s2 > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    s2 -= estado.danoFinal;
                    System.out.println("-> Atacaste al Slime 2 causando " + estado.danoFinal + " de dano.");
                }
                if (s3 > 0) {
                    orquestadorReliquias("AL_ATACAR", estado);
                    s3 -= estado.danoFinal;
                    System.out.println("-> Atacaste al Slime 3 causando " + estado.danoFinal + " de dano.");
                }
            } else {
                defendiendo = true;
                System.out.println("-> Te proteges de la ofensiva. El dano recibido se reduce en un 50%.");
            }

            System.out.println("-----------------------------------------");

            if (s1 > 0) {
                estado.danoEntrante = defendiendo ? 2 : 5;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- El Slime 1 te ataca e inflige " + estado.danoEntrante + " de dano.");
                if (estado.danoReflejado > 0) s1 -= estado.danoReflejado;
            }
            if (s2 > 0) {
                estado.danoEntrante = defendiendo ? 2 : 5;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- El Slime 2 te ataca e inflige " + estado.danoEntrante + " de dano.");
                if (estado.danoReflejado > 0) s2 -= estado.danoReflejado;
            }
            if (s3 > 0) {
                estado.danoEntrante = defendiendo ? 2 : 5;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- El Slime 3 te ataca e inflige " + estado.danoEntrante + " de dano.");
                if (estado.danoReflejado > 0) s3 -= estado.danoReflejado;
            }

            System.out.println("=========================================");
            System.out.println("Presiona ENTER para continuar...");
            esperarTecla();

        } while (!((s1 <= 0 && s2 <= 0 && s3 <= 0) || estado.vidaActual <= 0));
    }

    // -----------------------------------------------------------------
    // SALA DE JEFE FINAL: DRAGON COLOSAL
    // -----------------------------------------------------------------
    public static void salaJefeFinal(EstadoJuego estado) {
        int dragonHP = 400;
        String accion;
        boolean defendiendo, dragonCargandoFuego = false;
        int tipoAtaqueDragon, turnosRecargaLlamarada = 0;

        do {
            defendiendo = false;

            if (turnosRecargaLlamarada > 0) {
                turnosRecargaLlamarada--;
            }

            do {
                limpiarPantalla();
                System.out.println("=========================================");
                System.out.println("   ¡BATALLA FINAL: DRAGON COLOSAL!       ");
                System.out.println("=========================================");
                System.out.println("HP Jugador: " + estado.vidaActual + " / " + estado.vidaMaxima);
                System.out.println("Dragon Colosal HP: " + dragonHP + " / 400");
                System.out.println("-----------------------------------------");

                if (dragonCargandoFuego) {
                    System.out.println("[!] ¡ADVERTENCIA! El Dragon esta acumulando fuego en su garganta...");
                    System.out.println("[!] ¡Llamarada devastadora inminente para el siguiente turno!");
                } else {
                    System.out.println("[*] El Dragon acecha y ruge con furia.");
                }

                System.out.println("-----------------------------------------");
                System.out.println("1: Atacar | 2: Defender | 3: Inventario");
                accion = leerOpcion();

                if (accion.equals("3")) {
                    verInventarioCombate(estado);
                    accion = "0";
                } else if (!accion.equals("1") && !accion.equals("2")) {
                    System.out.println("Accion invalida. Selecciona 1, 2 o 3.");
                    esperarSegundos(2);
                }
            } while (!accion.equals("1") && !accion.equals("2"));

            limpiarPantalla();
            System.out.println("=========================================");
            System.out.println("           ACCION DEL TURNO              ");
            System.out.println("=========================================");

            orquestadorReliquias("INICIO_TURNO", estado);
            if (estado.danoAreaTurno > 0) {
                dragonHP -= estado.danoAreaTurno;
            }

            if (accion.equals("1")) {
                orquestadorReliquias("AL_ATACAR", estado);
                dragonHP -= estado.danoFinal;
                System.out.println("-> Atacaste al Dragon Colosal causando " + estado.danoFinal + " de dano.");
            } else {
                defendiendo = true;
                System.out.println("-> Te pones en guardia. El dano recibido se reduce en un 50%.");
            }

            System.out.println("-----------------------------------------");

            if (dragonCargandoFuego) {
                estado.danoEntrante = defendiendo ? 50 : 100;
                orquestadorReliquias("AL_RECIBIR_DANO", estado);
                estado.vidaActual -= estado.danoEntrante;
                System.out.println("<- ¡El Dragon desata su LLAMARADA DE FUEGO e inflige " + estado.danoEntrante + " de dano!");

                dragonCargandoFuego = false;
                turnosRecargaLlamarada = 3;
            } else {
                if (turnosRecargaLlamarada == 0) {
                    tipoAtaqueDragon = aleatorio(1, 3);
                } else {
                    tipoAtaqueDragon = aleatorio(1, 2);
                }

                if (tipoAtaqueDragon == 1) {
                    estado.danoEntrante = defendiendo ? 10 : 20;
                    orquestadorReliquias("AL_RECIBIR_DANO", estado);
                    estado.vidaActual -= estado.danoEntrante;
                    System.out.println("<- El Dragon te golpea con su Garra e inflige " + estado.danoEntrante + " de dano.");
                } else if (tipoAtaqueDragon == 2) {
                    estado.danoEntrante = defendiendo ? 15 : 30;
                    orquestadorReliquias("AL_RECIBIR_DANO", estado);
                    estado.vidaActual -= estado.danoEntrante;
                    System.out.println("<- El Dragon te barre con su Cola e inflige " + estado.danoEntrante + " de dano.");
                } else {
                    dragonCargandoFuego = true;
                    System.out.println("<- ¡El Dragon respira hondo y comienza a cargar una Llamarada de Fuego!");
                }
            }

            if (estado.danoReflejado > 0) {
                dragonHP -= estado.danoReflejado;
            }

            System.out.println("=========================================");
            System.out.println("Presiona ENTER para continuar...");
            esperarTecla();

        } while (!(dragonHP <= 0 || estado.vidaActual <= 0));
    }

    // -----------------------------------------------------------------
    // ALGORITMO PRINCIPAL
    // -----------------------------------------------------------------
    public static void main(String[] args) {
        EstadoJuego estado = new EstadoJuego();
        int pasoActual = 1;
        int enemigoIzquierda, enemigoDerecha;
        int tipoSalaElegida = 0;
        int ultimaSalaSuperada = 0;
        String opcionCamino;

        // PANTALLA DE INICIO
        limpiarPantalla();
        System.out.println("=========================================================================");
        System.out.println("  ____  ____  _____ _   _ ____   ___    ____  _   _ _   _  ____ _____ ___ _   _ ");
        System.out.println(" |  _ \\/ ___|| ____| | | |  _ \\ / _ \\  |  _ \\| | | | \\ | |/ ___| ____/ _ \\| \\ | |");
        System.out.println(" | |_) \\___ \\|  _| | | | | | | | | | | | | | | | | |  \\| | |  _|  _|| | | |  \\| |");
        System.out.println(" |  __/ ___) | |___| |_| | |_| | |_| | | |_| | |_| | |\\  | |_| | |__| |_| | |\\  |");
        System.out.println(" |_|   |____/|_____|\\___/|____/ \\___/  |____/ \\___/|_| \\_|\\____|_____\\___/|_| \\_|");
        System.out.println("=========================================================================\n");
        System.out.println("  COMO JUGAR:");
        System.out.println("  * Selecciona tus movimientos y ataques usando opciones multiples.");
        System.out.println("  * Explora y sobrevive a traves de 8 pisos llenos de monstruos.");
        System.out.println("  * Equipa reliquias pasivas y visita al mercader para fortalecerte.");
        System.out.println("  * Al final te espera un Jefe Colosal: derrotarlo te dara la victoria.\n");
        System.out.println("=========================================================================\n");
        System.out.print("                Oprime ENTER para empezar...");
        esperarTecla();
        limpiarPantalla();

        do {
            while (pasoActual <= 8) {
                enemigoIzquierda = aleatorio(1, 5);
                enemigoDerecha = aleatorio(1, 5);
                while (enemigoDerecha == enemigoIzquierda) {
                    enemigoDerecha = aleatorio(1, 5);
                }

                do {
                    mostrarMapaCompacto(pasoActual, estado.oro, enemigoIzquierda, enemigoDerecha, ultimaSalaSuperada);
                    System.out.print("      Elige tu opcion (1, 2 o 3): ");
                    opcionCamino = leerOpcion();

                    if (opcionCamino.equals("3")) {
                        salaTienda(estado);
                    } else if (!opcionCamino.equals("1") && !opcionCamino.equals("2")) {
                        System.out.println("Entrada no valida. Elige 1, 2 o 3.");
                        esperarSegundos(2);
                    }
                } while (!opcionCamino.equals("1") && !opcionCamino.equals("2"));

                tipoSalaElegida = opcionCamino.equals("1") ? enemigoIzquierda : enemigoDerecha;

                switch (tipoSalaElegida) {
                    case 1: salaGenerada1(estado); break;
                    case 2: salaGenerada2(estado); break;
                    case 3: salaGenerada3(estado); break;
                    case 4: salaGenerada4(estado); break;
                    case 5: salaGenerada5(estado); break;
                }

                limpiarPantalla();
                System.out.println("SECCION COMPLETADA");
                esperarSegundos(2);

                if (estado.vidaActual > 0) {
                    ultimaSalaSuperada = tipoSalaElegida;
                    pasoActual++;

                    if (tipoSalaElegida == 4) {
                        estado.oro += 60;
                        System.out.println("¡Has derrotado al Golem! Bono de elite: ¡Ganaste 60 de oro!");
                    } else {
                        estado.oro += 30;
                        System.out.println("Has superado el piso! Ganaste 30 de oro.");
                    }

                    orquestadorReliquias("FIN_SALA", estado);
                    esperarSegundos(2.5);

                    abrirCofrePostCombate(estado);
                } else {
                    pasoActual = 9;
                }

                limpiarPantalla();
            }
        } while (pasoActual <= 8);

        // JEFE FINAL
        if (estado.vidaActual > 0) {
            limpiarPantalla();
            System.out.println("=========================================");
            System.out.println(" ¡HAS LLEGADO AL ABISMO DEL JEFE FINAL!  ");
            System.out.println("=========================================");
            System.out.println("El Dragon Colosal alza el vuelo ante ti...");
            esperarSegundos(3);

            salaJefeFinal(estado);

            limpiarPantalla();
            if (estado.vidaActual > 0) {
                System.out.println("=========================================");
                System.out.println(" VICTORIA TOTAL! Has derrotado al Dragon.");
                System.out.println("=========================================");
            } else {
                System.out.println("=========================================");
                System.out.println("  GAME OVER - Caiste ante el Jefe Final. ");
                System.out.println("=========================================");
            }
        } else {
            System.out.println("=========================================");
            System.out.println("  GAME OVER - Has sido derrotado.");
            System.out.println("=========================================");
        }
    }
}