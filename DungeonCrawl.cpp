#include <iostream>
#include <string>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <thread>
#include <chrono>

using namespace std;

// -----------------------------------------------------------------
// UTILIDADES DE CONSOLA (Equivalentes a PSeInt)
// -----------------------------------------------------------------
void limpiarPantalla() {
#ifdef _WIN32
    system("cls");
#else
    system("clear");
#endif
}

void esperarSegundos(double segundos) {
    int milisegundos = static_cast<int>(segundos * 1000);
    this_thread::sleep_for(chrono::milliseconds(milisegundos));
}

void esperarTecla() {
    string temp;
    getline(cin, temp);
}

int aleatorio(int minVal, int maxVal) {
    return minVal + rand() % (maxVal - minVal + 1);
}

string leerOpcion() {
    string entrada;
    getline(cin, entrada);
    // Eliminar posibles espacios o retornos de carro
    while (!entrada.empty() && (entrada.back() == '\r' || entrada.back() == ' ')) {
        entrada.pop_back();
    }
    return entrada;
}

// -----------------------------------------------------------------
// BASE DE DATOS DE RELIQUIAS Y DESCRIPCIONES CORTAS
// -----------------------------------------------------------------
void obtenerDetallesReliquia(int id, string& nombre, string& descripcion) {
    switch (id) {
        case 1:
            nombre = "Anillo de Defensa";
            descripcion = "+25 Vida Maxima y cura +25 HP";
            break;
        case 2:
            nombre = "Anillo Critico";
            descripcion = "25% probabilidad de golpe critico (x2)";
            break;
        case 3:
            nombre = "Collar de Espinas";
            descripcion = "Devuelve 10 de dano al atacante";
            break;
        case 4:
            nombre = "Monedero";
            descripcion = "+15 monedas extra al superar salas";
            break;
        case 5:
            nombre = "Mazo de Obsidiana";
            descripcion = "+12 de dano fisico permanente";
            break;
        case 6:
            nombre = "Excalibur";
            descripcion = "+10 de dano fisico legendario";
            break;
        case 7:
            nombre = "Daga Venenosa";
            descripcion = "+6 de dano venenoso por impacto";
            break;
        case 8:
            nombre = "Bomba de Humo";
            descripcion = "20% probabilidad de esquivar ataques";
            break;
        case 9:
            nombre = "Daga Vampirica";
            descripcion = "Cura el 20% del dano infligido";
            break;
        case 10:
            nombre = "Libro Volcanico";
            descripcion = "8 de dano de fuego en area por turno";
            break;
        default:
            nombre = "Vacio";
            descripcion = "Sin objeto equipado";
            break;
    }
}

// -----------------------------------------------------------------
// PISTAS AMBIENTALES PARA LAS SALAS DEL MAPA
// -----------------------------------------------------------------
void obtenerPistaSala(int tipoSala, string& pista) {
    switch (tipoSala) {
        case 1: pista = "Se escuchan grunidos y un fuerte olor a muerto..."; break;
        case 2: pista = "Pasos arrastrados y el crujir de huesos viejos..."; break;
        case 3: pista = "Un burbujeo viscoso seguido del choque de huesos..."; break;
        case 4: pista = "Tienes un mal presentimiento... no creo que sea buena idea."; break;
        case 5: pista = "El suelo vibra con un chapoteo gelatinoso y acido..."; break;
        default: pista = "Un pasillo oscuro y silencioso..."; break;
    }
}

// -----------------------------------------------------------------
// FUNCION AUXILIAR: Verifica si el jugador tiene una reliquia equipada
// -----------------------------------------------------------------
bool tieneReliquia(const vector<string>& inventarioReliquias, const string& nombreBuscado) {
    for (int i = 1; i <= 5; i++) {
        if (inventarioReliquias[i] == nombreBuscado) {
            return true;
        }
    }
    return false;
}

// -----------------------------------------------------------------
// ORQUESTADOR DE RELIQUIAS (Controlador central de efectos pasivos)
// -----------------------------------------------------------------
void orquestadorReliquias(string fase, vector<string>& inventarioReliquias, int& vidaActual, int vidaMaxima,
                          int danoBase, int& danoFinal, int& danoEntrante, int& danoReflejado,
                          int& danoAreaTurno, int& oro) {
    int curacionVampirica;

    danoFinal = danoBase;
    danoReflejado = 0;
    danoAreaTurno = 0;

    // FASE 1: INICIO DEL TURNO
    if (fase == "INICIO_TURNO") {
        if (tieneReliquia(inventarioReliquias, "Libro Volcanico")) {
            danoAreaTurno = 8;
            cout << "[Reliquia: Libro Volcanico] Las llamas queman a todos los enemigos (-8 HP).\n";
        }
    }

    // FASE 2: AL ATACAR
    if (fase == "AL_ATACAR") {
        if (tieneReliquia(inventarioReliquias, "Anillo Critico")) {
            if (aleatorio(1, 100) <= 25) {
                danoFinal = danoFinal * 2;
                cout << "[Reliquia: Anillo Critico] ¡GOLPE CRITICO! Dano duplicado a " << danoFinal << ".\n";
            }
        }

        if (tieneReliquia(inventarioReliquias, "Daga Venenosa")) {
            danoFinal = danoFinal + 6;
            cout << "[Reliquia: Daga Venenosa] Veneno aplicado (+6 de dano extra).\n";
        }

        if (tieneReliquia(inventarioReliquias, "Daga Vampirica")) {
            curacionVampirica = static_cast<int>(danoFinal * 0.20);
            if (curacionVampirica < 1) {
                curacionVampirica = 1;
            }
            if (vidaActual < vidaMaxima) {
                vidaActual = vidaActual + curacionVampirica;
                if (vidaActual > vidaMaxima) {
                    vidaActual = vidaMaxima;
                }
                cout << "[Reliquia: Daga Vampirica] Absorbes " << curacionVampirica << " HP del enemigo.\n";
            }
        }
    }

    // FASE 3: AL RECIBIR DANO
    if (fase == "AL_RECIBIR_DANO") {
        if (tieneReliquia(inventarioReliquias, "Bomba de Humo")) {
            if (aleatorio(1, 100) <= 20) {
                danoEntrante = 0;
                cout << "[Reliquia: Bomba de Humo] ¡Desapareces en el humo y esquivas el ataque!\n";
            }
        }

        if (tieneReliquia(inventarioReliquias, "Collar de Espinas")) {
            danoReflejado = 10;
            cout << "[Reliquia: Collar de Espinas] Las espinas devuelven 10 de dano al atacante.\n";
        }
    }

    // FASE 4: FIN DE SALA
    if (fase == "FIN_SALA") {
        if (tieneReliquia(inventarioReliquias, "Monedero")) {
            oro = oro + 15;
            cout << "[Reliquia: Monedero] ¡Encuentras 15 monedas de oro adicionales!\n";
        }
    }
}

// -----------------------------------------------------------------
// INTERFAZ DE INVENTARIO EN COMBATE
// -----------------------------------------------------------------
void verInventarioCombate(int& cantidadPociones, vector<string>& inventarioReliquias, int totalReliquiasEquipadas,
                          int& vidaActual, int vidaMaxima, int danoJugador, int oro) {
    string opcionInv;

    do {
        limpiarPantalla();
        cout << "=========================================\n";
        cout << "          INVENTARIO DEL JUGADOR         \n";
        cout << "=========================================\n";
        cout << "Vida: " << vidaActual << " / " << vidaMaxima << "\n";
        cout << "Dano base actual: " << danoJugador << "\n";
        cout << "Oro disponible: " << oro << " monedas\n";
        cout << "Pociones disponibles: " << cantidadPociones << "\n";
        cout << "-----------------------------------------\n";
        cout << "SLOTS DE RELIQUIAS PASIVAS (" << totalReliquiasEquipadas << " / 5):\n";

        for (int i = 1; i <= 5; i++) {
            if (i <= totalReliquiasEquipadas) {
                cout << "  [Slot " << i << "] -> " << inventarioReliquias[i] << "\n";
            } else {
                cout << "  [Slot " << i << "] -> [ Vacio ]\n";
            }
        }

        cout << "=========================================\n";
        cout << " [1] Usar una Pocion (+50 HP)\n";
        cout << " [2] Salir del Inventario (Volver al combate)\n";
        cout << "=========================================\n";
        cout << "Elige una opcion: ";
        opcionInv = leerOpcion();

        if (opcionInv == "1") {
            if (cantidadPociones > 0) {
                if (vidaActual < vidaMaxima) {
                    cantidadPociones--;
                    vidaActual += 50;
                    if (vidaActual > vidaMaxima) {
                        vidaActual = vidaMaxima;
                    }
                    cout << "¡Te has tomado una pocion! Recuperas salud.\n";
                    esperarSegundos(2.5);
                } else {
                    cout << "¡Tienes la vida a tope!\n";
                    esperarSegundos(2.5);
                }
            } else {
                cout << "¡No tienes pociones disponibles!\n";
                esperarSegundos(2.5);
            }
        } else if (opcionInv != "2") {
            cout << "Opcion invalida. Elige 1 o 2.\n";
            esperarSegundos(2);
        }
    } while (opcionInv != "2");
}

// -----------------------------------------------------------------
// SISTEMA DE COFRE POST-COMBATE
// -----------------------------------------------------------------
void abrirCofrePostCombate(vector<string>& inventarioReliquias, int& totalReliquiasEquipadas, int& oro,
                           int& danoJugador, int& vidaActual, int& vidaMaxima) {
    int id1, id2;
    string nombre1, descripcion1, nombre2, descripcion2;
    string opcionCofre, reliquiaElegida, reliquiaDescartada, opcionReemplazo;
    bool esRepetida;
    int slotAElegir = 1;

    // Sortear Reliquia 1
    do {
        id1 = aleatorio(1, 10);
        obtenerDetallesReliquia(id1, nombre1, descripcion1);
        esRepetida = false;
        for (int i = 1; i <= totalReliquiasEquipadas; i++) {
            if (inventarioReliquias[i] == nombre1) {
                esRepetida = true;
            }
        }
    } while (esRepetida);

    // Sortear Reliquia 2
    do {
        id2 = aleatorio(1, 10);
        obtenerDetallesReliquia(id2, nombre2, descripcion2);
        esRepetida = false;
        if (id2 == id1) {
            esRepetida = true;
        } else {
            for (int i = 1; i <= totalReliquiasEquipadas; i++) {
                if (inventarioReliquias[i] == nombre2) {
                    esRepetida = true;
                }
            }
        }
    } while (esRepetida);

    // Menu principal del cofre
    do {
        limpiarPantalla();
        cout << "=========================================\n";
        cout << "            ¡SALA SUPERADA!             \n";
        cout << "           ¡ABRISTE UN COFRE!           \n";
        cout << "=========================================\n";
        cout << " Elige una reliquia para tu inventario:  \n\n";
        cout << " [1] " << nombre1 << "\n";
        cout << "     - " << descripcion1 << "\n\n";
        cout << " [2] " << nombre2 << "\n";
        cout << "     - " << descripcion2 << "\n\n";
        cout << " [3] Rechazar ambas (Recibir 30 de Oro)\n";
        cout << "=========================================\n";
        cout << " Espacios ocupados: [ " << totalReliquiasEquipadas << " / 5 ]\n";
        cout << "=========================================\n";
        cout << " Elige tu opcion (1, 2 o 3): ";
        opcionCofre = leerOpcion();

        if (opcionCofre != "1" && opcionCofre != "2" && opcionCofre != "3") {
            cout << "Entrada no valida. Elige 1, 2 o 3.\n";
            esperarSegundos(2);
        }
    } while (opcionCofre != "1" && opcionCofre != "2" && opcionCofre != "3");

    if (opcionCofre == "1" || opcionCofre == "2") {
        reliquiaElegida = (opcionCofre == "1") ? nombre1 : nombre2;

        if (totalReliquiasEquipadas < 5) {
            totalReliquiasEquipadas++;
            inventarioReliquias[totalReliquiasEquipadas] = reliquiaElegida;
            cout << "¡Has obtenido y equipado: " << reliquiaElegida << "!\n";

            if (reliquiaElegida == "Mazo de Obsidiana") {
                danoJugador += 12;
            } else if (reliquiaElegida == "Excalibur") {
                danoJugador += 10;
            } else if (reliquiaElegida == "Anillo de Defensa") {
                vidaMaxima += 25;
                vidaActual += 25;
            }
            esperarSegundos(3);
        } else {
            do {
                limpiarPantalla();
                cout << "=========================================\n";
                cout << "      ¡INVENTARIO LLENO (5 / 5)!         \n";
                cout << "=========================================\n";
                cout << " Intentas equipar: " << reliquiaElegida << "\n";
                cout << " Selecciona que slot deseas reemplazar:\n";
                cout << "-----------------------------------------\n";
                for (int i = 1; i <= 5; i++) {
                    cout << " [" << i << "] Reemplazar a: " << inventarioReliquias[i] << "\n";
                }
                cout << " [6] Arrepentirse y llevarse 30 de oro\n";
                cout << "=========================================\n";
                cout << "Elige una opcion (1 a 6): ";
                opcionReemplazo = leerOpcion();

                if (opcionReemplazo != "1" && opcionReemplazo != "2" && opcionReemplazo != "3" &&
                    opcionReemplazo != "4" && opcionReemplazo != "5" && opcionReemplazo != "6") {
                    cout << "Entrada no valida. Elige del 1 al 6.\n";
                    esperarSegundos(2);
                }
            } while (opcionReemplazo != "1" && opcionReemplazo != "2" && opcionReemplazo != "3" &&
                     opcionReemplazo != "4" && opcionReemplazo != "5" && opcionReemplazo != "6");

            if (opcionReemplazo != "6") {
                slotAElegir = stoi(opcionReemplazo);
                reliquiaDescartada = inventarioReliquias[slotAElegir];

                if (reliquiaDescartada == "Mazo de Obsidiana") {
                    danoJugador -= 12;
                } else if (reliquiaDescartada == "Excalibur") {
                    danoJugador -= 10;
                } else if (reliquiaDescartada == "Anillo de Defensa") {
                    vidaMaxima -= 25;
                    if (vidaActual > vidaMaxima) {
                        vidaActual = vidaMaxima;
                    }
                }

                cout << "¡Has descartado a " << reliquiaDescartada << " y equipado " << reliquiaElegida << "!\n";
                inventarioReliquias[slotAElegir] = reliquiaElegida;

                if (reliquiaElegida == "Mazo de Obsidiana") {
                    danoJugador += 12;
                } else if (reliquiaElegida == "Excalibur") {
                    danoJugador += 10;
                } else if (reliquiaElegida == "Anillo de Defensa") {
                    vidaMaxima += 25;
                    vidaActual += 25;
                }
                esperarSegundos(3);
            } else {
                oro += 30;
                cout << "Has decidido conservar tus reliquias. Obtienes 30 de oro.\n";
                esperarSegundos(2.5);
            }
        }
    } else {
        oro += 30;
        cout << "Has rechazado las reliquias. Obtienes 30 de oro.\n";
        esperarSegundos(2.5);
    }
    limpiarPantalla();
}

// -----------------------------------------------------------------
// MAPA COMPACTO DE LA MAZMORRA
// -----------------------------------------------------------------
void mostrarMapaCompacto(int pasoActual, int oro, int enemigoIzquierda, int enemigoDerecha, int ultimaSalaSuperada) {
    string pistaIzquierda, pistaDerecha;

    obtenerPistaSala(enemigoIzquierda, pistaIzquierda);
    obtenerPistaSala(enemigoDerecha, pistaDerecha);

    limpiarPantalla();
    cout << "===================================================================\n";
    cout << "                       MAPA DE LA MAZMORRA                         \n";
    cout << "===================================================================\n";

    if (pasoActual > 1) {
        cout << " [Rastro] Piso " << (pasoActual - 1) << " (Sala " << ultimaSalaSuperada << ") -> Piso " << pasoActual << " (Actual)\n";
    } else {
        cout << " [Inicio de aventura] -> Piso 1 (Actual)\n";
    }

    cout << " Oro actual: " << oro << " monedas\n";
    cout << "-------------------------------------------------------------------\n";
    cout << "                         ELIGE TU CAMINO:                          \n\n";
    cout << "   [1] -> " << pistaIzquierda << "\n";
    cout << "   [2] -> " << pistaDerecha << "\n";
    cout << "   [3] -> Visitar la Tienda del Mercader\n";
    cout << "===================================================================\n";
}

// -----------------------------------------------------------------
// TIENDA DEL MERCADER
// -----------------------------------------------------------------
void salaTienda(int& vidaActual, int& vidaMaxima, int& danoJugador, int& cantidadPociones, int& oro) {
    string opcionTienda;

    do {
        limpiarPantalla();
        cout << "=========================================\n";
        cout << "           TIENDA DEL MERCADER           \n";
        cout << "=========================================\n";
        cout << "Tu Oro disponible: " << oro << " monedas\n";
        cout << "Tu Vida: " << vidaActual << " / " << vidaMaxima << "\n";
        cout << "Tu Dano actual: " << danoJugador << "\n";
        cout << "Tus Pociones: " << cantidadPociones << "\n";
        cout << "-----------------------------------------\n";
        cout << " [1] Comprar 1 Pocion extra       (Costo: 20 oro)\n";
        cout << " [2] Frasco de Vida Maxima (+50 HP) (Costo: 50 oro)\n";
        cout << " [3] Afilar arma (+10 de dano)      (Costo: 40 oro)\n";
        cout << " [4] Salir de la tienda\n";
        cout << "=========================================\n";
        cout << "Elige una opcion: ";
        opcionTienda = leerOpcion();

        if (opcionTienda == "1") {
            if (oro >= 20) {
                oro -= 20;
                cantidadPociones++;
                cout << "¡Has comprado 1 pocion extra!\n";
            } else {
                cout << "¡No tienes suficiente oro (requieres 20)!\n";
            }
            esperarSegundos(2.5);
        } else if (opcionTienda == "2") {
            if (oro >= 50) {
                oro -= 50;
                vidaMaxima += 50;
                vidaActual += 50;
                cout << "¡Te bebiste un tonico supremo! Tu vida maxima aumenta.\n";
            } else {
                cout << "¡No tienes suficiente oro (requieres 50)!\n";
            }
            esperarSegundos(2.5);
        } else if (opcionTienda == "3") {
            if (oro >= 40) {
                oro -= 40;
                danoJugador += 10;
                cout << "¡Afilaste tu arma! Tu dano aumenta.\n";
            } else {
                cout << "¡No tienes suficiente oro (requieres 40)!\n";
            }
            esperarSegundos(2.5);
        } else if (opcionTienda == "4") {
            cout << "Sales de la tienda y continuas tu camino...\n";
            esperarSegundos(2);
        } else {
            cout << "Opcion invalida. Intentalo de nuevo.\n";
            esperarSegundos(2.5);
        }
    } while (opcionTienda != "4");
}

// -----------------------------------------------------------------
// SUBPROCESOS DE COMBATE
// -----------------------------------------------------------------

// --- SALA 1: DOS ZOMBIES ---
void salaGenerada1(int& vidaActual, int vidaMaxima, int danoJugador, int& cantidadPociones,
                   vector<string>& inventarioReliquias, int totalReliquiasEquipadas, int& oro) {
    int z1 = 50, z2 = 50, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy = 0;
    string accion;
    bool defendiendo;

    do {
        defendiendo = false;
        do {
            limpiarPantalla();
            cout << "=== SALA 1: DOS ZOMBIES ===\n";
            cout << "HP Jugador: " << vidaActual << " / " << vidaMaxima << "\n";
            cout << (z1 <= 0 ? "Zombi 1 HP: || M U E R T O ||\n" : "Zombi 1 HP: " + to_string(z1) + "\n");
            cout << (z2 <= 0 ? "Zombi 2 HP: || M U E R T O ||\n" : "Zombi 2 HP: " + to_string(z2) + "\n");
            cout << "-----------------------------------------\n";
            cout << "1: Atacar | 2: Defender | 3: Inventario\n";
            accion = leerOpcion();

            if (accion == "3") {
                verInventarioCombate(cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danoJugador, oro);
                accion = "0";
            } else if (accion != "1" && accion != "2") {
                cout << "Accion invalida. Selecciona 1, 2 o 3.\n";
                esperarSegundos(2);
            }
        } while (accion != "1" && accion != "2");

        limpiarPantalla();
        cout << "=========================================\n";
        cout << "           ACCION DEL TURNO              \n";
        cout << "=========================================\n";

        orquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
        if (danoAreaTurno > 0) {
            if (z1 > 0) z1 -= danoAreaTurno;
            if (z2 > 0) z2 -= danoAreaTurno;
        }

        if (accion == "1") {
            if (z1 > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                z1 -= danoFinal;
                cout << "-> Atacaste al Zombi 1 causando " << danoFinal << " de dano.\n";
            }
            if (z2 > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                z2 -= danoFinal;
                cout << "-> Atacaste al Zombi 2 causando " << danoFinal << " de dano.\n";
            }
        } else {
            defendiendo = true;
            cout << "-> Te pones en guardia. El dano recibido se reduce en un 50%.\n";
        }

        cout << "-----------------------------------------\n";

        if (z1 > 0) {
            danoEnemigo = 10;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- El Zombi 1 te ataca e inflige " << danoEnemigo << " de dano.\n";
            if (danoReflejado > 0) z1 -= danoReflejado;
        }
        if (z2 > 0) {
            danoEnemigo = 10;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- El Zombi 2 te ataca e inflige " << danoEnemigo << " de dano.\n";
            if (danoReflejado > 0) z2 -= danoReflejado;
        }

        cout << "=========================================\n";
        cout << "Presiona ENTER para continuar...";
        esperarTecla();

    } while (!((z1 <= 0 && z2 <= 0) || vidaActual <= 0));
}

// --- SALA 2: ZOMBI Y ESQUELETO ---
void salaGenerada2(int& vidaActual, int vidaMaxima, int danoJugador, int& cantidadPociones,
                   vector<string>& inventarioReliquias, int totalReliquiasEquipadas, int& oro) {
    int zombieHP = 50, esqueletoHP = 70, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy = 0;
    string accion;
    bool defendiendo;

    do {
        defendiendo = false;
        do {
            limpiarPantalla();
            cout << "=== SALA 2: ZOMBI Y ESQUELETO ===\n";
            cout << "HP Jugador: " << vidaActual << " / " << vidaMaxima << "\n";
            cout << (zombieHP <= 0 ? "Zombi HP: || M U E R T O ||\n" : "Zombi HP: " + to_string(zombieHP) + "\n");
            cout << (esqueletoHP <= 0 ? "Esqueleto HP: || M U E R T O ||\n" : "Esqueleto HP: " + to_string(esqueletoHP) + "\n");
            cout << "-----------------------------------------\n";
            cout << "1: Atacar | 2: Defender | 3: Inventario\n";
            accion = leerOpcion();

            if (accion == "3") {
                verInventarioCombate(cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danoJugador, oro);
                accion = "0";
            } else if (accion != "1" && accion != "2") {
                cout << "Accion invalida. Selecciona 1, 2 o 3.\n";
                esperarSegundos(2);
            }
        } while (accion != "1" && accion != "2");

        limpiarPantalla();
        cout << "=========================================\n";
        cout << "           ACCION DEL TURNO              \n";
        cout << "=========================================\n";

        orquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
        if (danoAreaTurno > 0) {
            if (zombieHP > 0) zombieHP -= danoAreaTurno;
            if (esqueletoHP > 0) esqueletoHP -= danoAreaTurno;
        }

        if (accion == "1") {
            if (zombieHP > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                zombieHP -= danoFinal;
                cout << "-> Atacaste al Zombi causando " << danoFinal << " de dano.\n";
            }
            if (esqueletoHP > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                esqueletoHP -= danoFinal;
                cout << "-> Atacaste al Esqueleto causando " << danoFinal << " de dano.\n";
            }
        } else {
            defendiendo = true;
            cout << "-> Te proteges del impacto. El dano recibido se reduce en un 50%.\n";
        }

        cout << "-----------------------------------------\n";

        if (zombieHP > 0) {
            danoEnemigo = 10;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- El Zombi te ataca e inflige " << danoEnemigo << " de dano.\n";
            if (danoReflejado > 0) zombieHP -= danoReflejado;
        }
        if (esqueletoHP > 0) {
            danoEnemigo = 15;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- El Esqueleto te ataca e inflige " << danoEnemigo << " de dano.\n";
            if (danoReflejado > 0) esqueletoHP -= danoReflejado;
        }

        cout << "=========================================\n";
        cout << "Presiona ENTER para continuar...";
        esperarTecla();

    } while (!((zombieHP <= 0 && esqueletoHP <= 0) || vidaActual <= 0));
}

// --- SALA 3: SLIME Y ESQUELETO ---
void salaGenerada3(int& vidaActual, int vidaMaxima, int danoJugador, int& cantidadPociones,
                   vector<string>& inventarioReliquias, int totalReliquiasEquipadas, int& oro) {
    int slimeHP = 40, esqueletoHP = 70, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy = 0;
    string accion;
    bool defendiendo;

    do {
        defendiendo = false;
        do {
            limpiarPantalla();
            cout << "=== SALA 3: SLIME Y ESQUELETO ===\n";
            cout << "HP Jugador: " << vidaActual << " / " << vidaMaxima << "\n";
            cout << (slimeHP <= 0 ? "Slime HP: || M U E R T O ||\n" : "Slime HP: " + to_string(slimeHP) + "\n");
            cout << (esqueletoHP <= 0 ? "Esqueleto HP: || M U E R T O ||\n" : "Esqueleto HP: " + to_string(esqueletoHP) + "\n");
            cout << "-----------------------------------------\n";
            cout << "1: Atacar | 2: Defender | 3: Inventario\n";
            accion = leerOpcion();

            if (accion == "3") {
                verInventarioCombate(cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danoJugador, oro);
                accion = "0";
            } else if (accion != "1" && accion != "2") {
                cout << "Accion invalida. Selecciona 1, 2 o 3.\n";
                esperarSegundos(2);
            }
        } while (accion != "1" && accion != "2");

        limpiarPantalla();
        cout << "=========================================\n";
        cout << "           ACCION DEL TURNO              \n";
        cout << "=========================================\n";

        orquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
        if (danoAreaTurno > 0) {
            if (slimeHP > 0) slimeHP -= danoAreaTurno;
            if (esqueletoHP > 0) esqueletoHP -= danoAreaTurno;
        }

        if (accion == "1") {
            if (slimeHP > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                slimeHP -= danoFinal;
                cout << "-> Atacaste al Slime causando " << danoFinal << " de dano.\n";
            }
            if (esqueletoHP > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                esqueletoHP -= danoFinal;
                cout << "-> Atacaste al Esqueleto causando " << danoFinal << " de dano.\n";
            }
        } else {
            defendiendo = true;
            cout << "-> Te defiendes. El dano recibido se reduce en un 50%.\n";
        }

        cout << "-----------------------------------------\n";

        if (slimeHP > 0) {
            danoEnemigo = 5;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- El Slime te ataca e inflige " << danoEnemigo << " de dano.\n";
            if (danoReflejado > 0) slimeHP -= danoReflejado;
        }
        if (esqueletoHP > 0) {
            danoEnemigo = 15;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- El Esqueleto te ataca e inflige " << danoEnemigo << " de dano.\n";
            if (danoReflejado > 0) esqueletoHP -= danoReflejado;
        }

        cout << "=========================================\n";
        cout << "Presiona ENTER para continuar...";
        esperarTecla();

    } while (!((slimeHP <= 0 && esqueletoHP <= 0) || vidaActual <= 0));
}

// --- SALA 4: GOLEM Y ZOMBI ---
void salaGenerada4(int& vidaActual, int vidaMaxima, int danoJugador, int& cantidadPociones,
                   vector<string>& inventarioReliquias, int totalReliquiasEquipadas, int& oro) {
    int golemHP = 200, zombieHP = 50, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy = 0;
    string accion;
    bool golemAtaca = false, defendiendo;

    do {
        defendiendo = false;
        do {
            limpiarPantalla();
            cout << "=== SALA 4: GOLEM Y ZOMBI ===\n";
            cout << "HP Jugador: " << vidaActual << " / " << vidaMaxima << "\n";
            cout << (golemHP <= 0 ? "Golem HP: || M U E R T O ||\n" : "Golem HP: " + to_string(golemHP) + "\n");
            cout << (zombieHP <= 0 ? "Zombi HP: || M U E R T O ||\n" : "Zombi HP: " + to_string(zombieHP) + "\n");

            if (golemAtaca) {
                cout << "[!] ¡El Golem esta listo para atacar este turno!\n";
            } else {
                cout << "[*] El Golem esta cargando energia...\n";
            }

            cout << "-----------------------------------------\n";
            cout << "1: Atacar | 2: Defender | 3: Inventario\n";
            accion = leerOpcion();

            if (accion == "3") {
                verInventarioCombate(cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danoJugador, oro);
                accion = "0";
            } else if (accion != "1" && accion != "2") {
                cout << "Accion invalida. Selecciona 1, 2 o 3.\n";
                esperarSegundos(2);
            }
        } while (accion != "1" && accion != "2");

        limpiarPantalla();
        cout << "=========================================\n";
        cout << "           ACCION DEL TURNO              \n";
        cout << "=========================================\n";

        orquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
        if (danoAreaTurno > 0) {
            if (golemHP > 0) golemHP -= danoAreaTurno;
            if (zombieHP > 0) zombieHP -= danoAreaTurno;
        }

        if (accion == "1") {
            if (golemHP > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                golemHP -= danoFinal;
                cout << "-> Atacaste al Golem causando " << danoFinal << " de dano.\n";
            }
            if (zombieHP > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                zombieHP -= danoFinal;
                cout << "-> Atacaste al Zombi causando " << danoFinal << " de dano.\n";
            }
        } else {
            defendiendo = true;
            cout << "-> Te defiendes de los ataques entrantes. El dano recibido se reduce en un 50%.\n";
        }

        cout << "-----------------------------------------\n";

        if (zombieHP > 0) {
            danoEnemigo = 10;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- El Zombi te ataca e inflige " << danoEnemigo << " de dano.\n";
            if (danoReflejado > 0) zombieHP -= danoReflejado;
        }

        if (golemHP > 0) {
            if (golemAtaca) {
                danoEnemigo = 30;
                if (defendiendo) danoEnemigo /= 2;
                orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
                vidaActual -= danoEnemigo;
                cout << "<- ¡El Golem desata su ataque masivo e inflige " << danoEnemigo << " de dano!\n";
                if (danoReflejado > 0) golemHP -= danoReflejado;
                golemAtaca = false;
            } else {
                cout << "<- El Golem ruge acumulando poder (sin dano este turno).\n";
                golemAtaca = true;
            }
        }

        cout << "=========================================\n";
        cout << "Presiona ENTER para continuar...";
        esperarTecla();

    } while (!((golemHP <= 0 && zombieHP <= 0) || vidaActual <= 0));
}

// --- SALA 5: TRES SLIMES ---
void salaGenerada5(int& vidaActual, int vidaMaxima, int danoJugador, int& cantidadPociones,
                   vector<string>& inventarioReliquias, int totalReliquiasEquipadas, int& oro) {
    int s1 = 40, s2 = 40, s3 = 40, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy = 0;
    string accion;
    bool defendiendo;

    do {
        defendiendo = false;
        do {
            limpiarPantalla();
            cout << "=== SALA 5: TRES SLIMES ===\n";
            cout << "HP Jugador: " << vidaActual << " / " << vidaMaxima << "\n";
            cout << (s1 <= 0 ? "Slime 1: || M U E R T O ||\n" : "Slime 1: " + to_string(s1) + "\n");
            cout << (s2 <= 0 ? "Slime 2: || M U E R T O ||\n" : "Slime 2: " + to_string(s2) + "\n");
            cout << (s3 <= 0 ? "Slime 3: || M U E R T O ||\n" : "Slime 3: " + to_string(s3) + "\n");
            cout << "-----------------------------------------\n";
            cout << "1: Atacar | 2: Defender | 3: Inventario\n";
            accion = leerOpcion();

            if (accion == "3") {
                verInventarioCombate(cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danoJugador, oro);
                accion = "0";
            } else if (accion != "1" && accion != "2") {
                cout << "Accion invalida. Selecciona 1, 2 o 3.\n";
                esperarSegundos(2);
            }
        } while (accion != "1" && accion != "2");

        limpiarPantalla();
        cout << "=========================================\n";
        cout << "           ACCION DEL TURNO              \n";
        cout << "=========================================\n";

        orquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
        if (danoAreaTurno > 0) {
            if (s1 > 0) s1 -= danoAreaTurno;
            if (s2 > 0) s2 -= danoAreaTurno;
            if (s3 > 0) s3 -= danoAreaTurno;
        }

        if (accion == "1") {
            if (s1 > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                s1 -= danoFinal;
                cout << "-> Atacaste al Slime 1 causando " << danoFinal << " de dano.\n";
            }
            if (s2 > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                s2 -= danoFinal;
                cout << "-> Atacaste al Slime 2 causando " << danoFinal << " de dano.\n";
            }
            if (s3 > 0) {
                orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
                s3 -= danoFinal;
                cout << "-> Atacaste al Slime 3 causando " << danoFinal << " de dano.\n";
            }
        } else {
            defendiendo = true;
            cout << "-> Te proteges de la ofensiva. El dano recibido se reduce en un 50%.\n";
        }

        cout << "-----------------------------------------\n";

        if (s1 > 0) {
            danoEnemigo = 5;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- El Slime 1 te ataca e inflige " << danoEnemigo << " de dano.\n";
            if (danoReflejado > 0) s1 -= danoReflejado;
        }
        if (s2 > 0) {
            danoEnemigo = 5;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- El Slime 2 te ataca e inflige " << danoEnemigo << " de dano.\n";
            if (danoReflejado > 0) s2 -= danoReflejado;
        }
        if (s3 > 0) {
            danoEnemigo = 5;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- El Slime 3 te ataca e inflige " << danoEnemigo << " de dano.\n";
            if (danoReflejado > 0) s3 -= danoReflejado;
        }

        cout << "=========================================\n";
        cout << "Presiona ENTER para continuar...";
        esperarTecla();

    } while (!((s1 <= 0 && s2 <= 0 && s3 <= 0) || vidaActual <= 0));
}

// -----------------------------------------------------------------
// SALA DE JEFE FINAL: DRAGON COLOSAL
// -----------------------------------------------------------------
void salaJefeFinal(int& vidaActual, int vidaMaxima, int danoJugador, int& cantidadPociones,
                   vector<string>& inventarioReliquias, int totalReliquiasEquipadas, int& oro) {
    int dragonHP = 400, danoEnemigo, danoFinal, danoReflejado, danoAreaTurno, dummy = 0;
    string accion;
    bool defendiendo, dragonCargandoFuego = false;
    int tipoAtaqueDragon, turnosRecargaLlamarada = 0;

    do {
        defendiendo = false;

        if (turnosRecargaLlamarada > 0) {
            turnosRecargaLlamarada--;
        }

        do {
            limpiarPantalla();
            cout << "=========================================\n";
            cout << "   ¡BATALLA FINAL: DRAGON COLOSAL!       \n";
            cout << "=========================================\n";
            cout << "HP Jugador: " << vidaActual << " / " << vidaMaxima << "\n";
            cout << "Dragon Colosal HP: " << dragonHP << " / 400\n";
            cout << "-----------------------------------------\n";

            if (dragonCargandoFuego) {
                cout << "[!] ¡ADVERTENCIA! El Dragon esta acumulando fuego en su garganta...\n";
                cout << "[!] ¡Llamarada devastadora inminente para el siguiente turno!\n";
            } else {
                cout << "[*] El Dragon acecha y ruge con furia.\n";
            }

            cout << "-----------------------------------------\n";
            cout << "1: Atacar | 2: Defender | 3: Inventario\n";
            accion = leerOpcion();

            if (accion == "3") {
                verInventarioCombate(cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, vidaActual, vidaMaxima, danoJugador, oro);
                accion = "0";
            } else if (accion != "1" && accion != "2") {
                cout << "Accion invalida. Selecciona 1, 2 o 3.\n";
                esperarSegundos(2);
            }
        } while (accion != "1" && accion != "2");

        limpiarPantalla();
        cout << "=========================================\n";
        cout << "           ACCION DEL TURNO              \n";
        cout << "=========================================\n";

        orquestadorReliquias("INICIO_TURNO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
        if (danoAreaTurno > 0) {
            dragonHP -= danoAreaTurno;
        }

        if (accion == "1") {
            orquestadorReliquias("AL_ATACAR", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, dummy, danoReflejado, danoAreaTurno, oro);
            dragonHP -= danoFinal;
            cout << "-> Atacaste al Dragon Colosal causando " << danoFinal << " de dano.\n";
        } else {
            defendiendo = true;
            cout << "-> Te pones en guardia. El dano recibido se reduce en un 50%.\n";
        }

        cout << "-----------------------------------------\n";

        if (dragonCargandoFuego) {
            danoEnemigo = 100;
            if (defendiendo) danoEnemigo /= 2;
            orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
            vidaActual -= danoEnemigo;
            cout << "<- ¡El Dragon desata su LLAMARADA DE FUEGO e inflige " << danoEnemigo << " de dano!\n";

            dragonCargandoFuego = false;
            turnosRecargaLlamarada = 3;
        } else {
            if (turnosRecargaLlamarada == 0) {
                tipoAtaqueDragon = aleatorio(1, 3);
            } else {
                tipoAtaqueDragon = aleatorio(1, 2);
            }

            if (tipoAtaqueDragon == 1) {
                danoEnemigo = 20;
                if (defendiendo) danoEnemigo /= 2;
                orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
                vidaActual -= danoEnemigo;
                cout << "<- El Dragon te golpea con su Garra e inflige " << danoEnemigo << " de dano.\n";
            } else if (tipoAtaqueDragon == 2) {
                danoEnemigo = 30;
                if (defendiendo) danoEnemigo /= 2;
                orquestadorReliquias("AL_RECIBIR_DANO", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, danoFinal, danoEnemigo, danoReflejado, danoAreaTurno, oro);
                vidaActual -= danoEnemigo;
                cout << "<- El Dragon te barre con su Cola e inflige " << danoEnemigo << " de dano.\n";
            } else {
                dragonCargandoFuego = true;
                cout << "<- ¡El Dragon respira hondo y comienza a cargar una Llamarada de Fuego!\n";
            }
        }

        if (danoReflejado > 0) {
            dragonHP -= danoReflejado;
        }

        cout << "=========================================\n";
        cout << "Presiona ENTER para continuar...";
        esperarTecla();

    } while (!(dragonHP <= 0 || vidaActual <= 0));
}

// -----------------------------------------------------------------
// ALGORITMO PRINCIPAL
// -----------------------------------------------------------------
int main() {
    srand(static_cast<unsigned int>(time(nullptr)));

    int pasoActual = 1;
    int vidaMaxima = 200;
    int vidaActual = 200;
    int cantidadPociones = 0;
    int enemigoIzquierda, enemigoDerecha;
    int oro = 0;
    int tipoSalaElegida = 0;
    int dummy1 = 0, dummy2 = 0, dummy3 = 0, dummy4 = 0;
    string opcionCamino;
    int danoJugador = 25;
    int ultimaSalaSuperada = 0;

    vector<string> inventarioReliquias(6, "Vacio");
    int totalReliquiasEquipadas = 0;

    // PANTALLA DE INICIO
    limpiarPantalla();
    cout << "=========================================================================\n";
    cout << "  ____  ____  _____ _   _ ____   ___    ____  _   _ _   _  ____ _____ ___ _   _ \n";
    cout << " |  _ \\/ ___|| ____| | | |  _ \\ / _ \\  |  _ \\| | | | \\ | |/ ___| ____/ _ \\| \\ | |\n";
    cout << " | |_) \\___ \\|  _| | | | | | | | | | | | | | | | | |  \\| | |  _|  _|| | | |  \\| |\n";
    cout << " |  __/ ___) | |___| |_| | |_| | |_| | | |_| | |_| | |\\  | |_| | |__| |_| | |\\  |\n";
    cout << " |_|   |____/|_____|\\___/|____/ \\___/  |____/ \\___/|_| \\_|\\____|_____\\___/|_| \\_|\n";
    cout << "=========================================================================\n\n";
    cout << "  COMO JUGAR:\n";
    cout << "  * Selecciona tus movimientos y ataques usando opciones multiples.\n";
    cout << "  * Explora y sobrevive a traves de 8 pisos llenos de monstruos.\n";
    cout << "  * Equipa reliquias pasivas y visita al mercader para fortalecerte.\n";
    cout << "  * Al final te espera un Jefe Colosal: derrotarlo te dara la victoria.\n\n";
    cout << "=========================================================================\n\n";
    cout << "                Oprime ENTER para empezar...";
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
                mostrarMapaCompacto(pasoActual, oro, enemigoIzquierda, enemigoDerecha, ultimaSalaSuperada);
                cout << "      Elige tu opcion (1, 2 o 3): ";
                opcionCamino = leerOpcion();

                if (opcionCamino == "3") {
                    salaTienda(vidaActual, vidaMaxima, danoJugador, cantidadPociones, oro);
                } else if (opcionCamino != "1" && opcionCamino != "2") {
                    cout << "Entrada no valida. Elige 1, 2 o 3.\n";
                    esperarSegundos(2);
                }
            } while (opcionCamino != "1" && opcionCamino != "2");

            tipoSalaElegida = (opcionCamino == "1") ? enemigoIzquierda : enemigoDerecha;

            switch (tipoSalaElegida) {
                case 1: salaGenerada1(vidaActual, vidaMaxima, danoJugador, cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, oro); break;
                case 2: salaGenerada2(vidaActual, vidaMaxima, danoJugador, cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, oro); break;
                case 3: salaGenerada3(vidaActual, vidaMaxima, danoJugador, cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, oro); break;
                case 4: salaGenerada4(vidaActual, vidaMaxima, danoJugador, cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, oro); break;
                case 5: salaGenerada5(vidaActual, vidaMaxima, danoJugador, cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, oro); break;
            }

            limpiarPantalla();
            cout << "SECCION COMPLETADA\n";
            esperarSegundos(2);

            if (vidaActual > 0) {
                ultimaSalaSuperada = tipoSalaElegida;
                pasoActual++;

                if (tipoSalaElegida == 4) {
                    oro += 60;
                    cout << "¡Has derrotado al Golem! Bono de elite: ¡Ganaste 60 de oro!\n";
                } else {
                    oro += 30;
                    cout << "Has superado el piso! Ganaste 30 de oro.\n";
                }

                orquestadorReliquias("FIN_SALA", inventarioReliquias, vidaActual, vidaMaxima, danoJugador, dummy1, dummy2, dummy3, dummy4, oro);
                esperarSegundos(2.5);

                abrirCofrePostCombate(inventarioReliquias, totalReliquiasEquipadas, oro, danoJugador, vidaActual, vidaMaxima);
            } else {
                pasoActual = 9;
            }

            limpiarPantalla();
        }
    } while (pasoActual <= 8);

    // JEFE FINAL
    if (vidaActual > 0) {
        limpiarPantalla();
        cout << "=========================================\n";
        cout << " ¡HAS LLEGADO AL ABISMO DEL JEFE FINAL!  \n";
        cout << "=========================================\n";
        cout << "El Dragon Colosal alza el vuelo ante ti...\n";
        esperarSegundos(3);

        salaJefeFinal(vidaActual, vidaMaxima, danoJugador, cantidadPociones, inventarioReliquias, totalReliquiasEquipadas, oro);

        limpiarPantalla();
        if (vidaActual > 0) {
            cout << "=========================================\n";
            cout << " VICTORIA TOTAL! Has derrotado al Dragon.\n";
            cout << "=========================================\n";
        } else {
            cout << "=========================================\n";
            cout << "  GAME OVER - Caiste ante el Jefe Final. \n";
            cout << "=========================================\n";
        }
    } else {
        cout << "=========================================\n";
        cout << "  GAME OVER - Has sido derrotado.\n";
        cout << "=========================================\n";
    }

    return 0;
}