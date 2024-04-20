import math
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
"""
Uma máquina de indução trifásica, com rotor em gaiola, 4 polos, 60Hz, 20cv, 550V, 1760rpm, foi submetida a ensaios, 
cujos resultados foram:

    No Load: 
        {
            Tensão (V): 550;
            Corrente (A): 5,8;
            Potência (W): 754;
            Frequência (Hz): 60;
        }
    Blocked Rotor:
        {
            Tensão (V): 123;
            Corrente (A): 25;
            Potência (W): 2419;
            Frequência (Hz): 0;
        }
    C.C Stator
        {
            Tensão (V): 15;
            Corrente (A): 25;
            Potência (W): -;
            Frequência (Hz): 0;
        }
        Declaração dos testes como variáveis do programa:
        As letras, V; I; P e F são referentes a "Tensão", "Corrente", "Potência" e "Frequência", respectivamente.
        Os Subscritos nl, br e cc são referentes a "No Load", "Blocked Rotor" e "C.C", respectivamente.
"""

# No Load

V_nl = 550
I_nl = 5.8
P_nl = 754
F_nl = 60

# Blocked Rotor

V_br = 123;
I_br = 25;
P_br = 2419;
F_br = 0;

# C.C

V_cc = 15;
I_cc = 25;
F_cc = 0;

"""
1) Determinação dos Parâmetros do circuito equivalente. 
        1.1) Declaração das Variáveis do circuito.
            Os Subscritos nl, br e cc são referentes a "No Load", "Blocked Rotor" e "C.C", respectivamente.
            R, Z e X são Resistência, Impedância e Reatância;

            No Load
                R_nl; 
                Z_nl; 
                X_nl;

            Blocked Rotor

                R_br;
                Z_br;
                X_br;

            Parâmetros de Circuito

                R_1; % Resistência de Estator
                R_2; % Resistência de Rotor
                X_1; % Reatância de Disperção Estator
                X_2; % Reatância de Disperção Rotor
                X_m; % Reatância de Magnetização
"""
# No ensaio a Vazio considerando X_m <<(R_2/s + jX_2) --> escorregamento muito baixo
# Cálculo de R_1

R_1 = (V_cc/I_cc)/2
print(f"Resistência de Estator = {R_1:.3f} \n")

# Cálculo de R_nl

R_nl = (P_nl/(3*pow(I_nl,2)));
print(f"Resistência Motor a Vazio = {R_nl:.3f} \n")

# Cálculo de Z_nl

Z_nl = V_nl/(math.sqrt(3)*I_nl);
print(f"Impedância Motor a Vazio = {Z_nl:.3f} \n")

# Cálculo de  X_nl

X_nl = math.sqrt((pow(Z_nl,2))-(pow(R_nl,2)))
print(f"Reatância Motor a Vazio = {X_nl:.3f} \n")


# No ensaio de Rotor Bloqueado, considerando X_m >> (R2/s + jX_2) --> escorregamento igual a 1

# Cálculo de R_br

R_br = P_br/(3*pow(I_br,2))
print(f"Resistência de Rotor Bloqueado = {R_br:.3f} \n")

# Cálculo de Z_br

Z_br = V_br/(math.sqrt(3)*I_br)
print(f"Resistência de Rotor Bloqueado = {Z_br:.3f} \n")

# Cálculo de X_br

X_br = math.sqrt(pow(Z_br,2)-pow(R_br,2))
print(f"Resistência de Rotor Bloqueado = {X_br:.3f} \n")

# Cálculo de R_2

R_2 = R_br - R_1
print(f"Resistência de Rotor = {R_2:.3f} \n")

# Cálculo de X_1 e X_2 e X_m

# Considerando (X_1/X_2) = 1

X_1 = X_br/2
print(f"Reatância de Disperção de Estator = {X_1:.3f} \n")

X_2 = X_br/2
print(f"Reatância de Disperção de Rotor = {X_2:.3f} \n")

X_m = X_nl - X_1
print(f"Reatância de Magnetização = {X_m:.3f} \n")

# Cálculo das Indutâncias
# A multiplicação por 1000 se dá para deixar as indutâncias em mH

w = 2*math.pi*60

L_1 = (X_1/w)
L_2 = (X_2/w)
L_m = (X_m/w)

L_1_tab = L_1*1000
L_2_tab = L_2*1000
L_m_tab = L_m*1000

# Apresentando Dados em Tabela

dados_tabela = {
    "Parâmetro":["R1", "R2", "X1", "X2", "L1", "L2", "Xm", "Lm" ],
    "Valor": [R_1, R_2, X_1, X_2, L_1_tab, L_2_tab, X_m, L_m_tab]
}

tabela = pd.DataFrame(dados_tabela)

tabela['Valor'] = tabela['Valor'].round(2)

tabela_str = tabela.to_string(index=False)

print(tabela_str)

"""
    2) Obtenção das curvas de Conjugado x Velocidade para a máquina com tensão nominal.
        Em N.m e pu
"""
# Definição de Parâmetros

polos = 4 # Nº de polos da máquina
freq_nominal = 60 # Frequência de operação da Máquina
n = 1760 # Velocidade Nominal em rpm

ns = (120/polos)*freq_nominal # Velocidade Síncrona

s = (ns - n)/ns # Escorregamento nominal

wm = (1-s)*ns # Velocidade Mecânica

V_nominal = 550/math.sqrt(3) # Tensão Nominal da Máquina Trifásica (Fase - Neutro)

# Inicialização de dois vetores de zeros de tamanho 100

potencia = []
torque = []
w_mecanico = []

velocidades = np.arange(0,2*ns,1).astype(int)


for n in velocidades:
    # Cálculo da Impedância Equivalente do Motor
    Z_1 = R_1 + X_1*1j
    Z_2 = (R_2/s) + X_2*1j
    X_m_rec = X_m*1j
    Z_paralelo = (X_m_rec*(Z_2))/(X_m_rec + Z_2)
    Z_equivalente = (Z_1 + Z_paralelo)
    s = (ns - n)/ns

    # Cálculo da Corrente de Entrada
    I_1 = V_nominal/Z_equivalente

    # Cálculo da Corrente de Rotor

    I_2 = (X_m_rec/(X_m_rec + Z_2))*I_1

    # Cálculo da Potência e Velocidade, Nota-se que Torque = Potencia / Velocidade Mecânica

    potencia.append(3*abs(pow(I_2,2))*(R_2/s)*(1-s))

    w_mecanico.append((1-s)*ns)
    #w_int = [int(i) for i in w_mecanico]
    torque.append(potencia[-1]/w_mecanico[-1])


plt.figure(figsize=(10, 6))

plt.plot(velocidades, torque, label='Torque vs Velocidade')

plt.xlabel('Velocidade [rpm]')

plt.ylabel('Torque [N.m]')

plt.grid(True)
plt.show()








