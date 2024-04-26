clear;
clc;


%{
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
%}

%{
    Declaração dos testes como variáveis do programa:
        As letras, V; I; P e F são referentes a "Tensão", "Corrente", "Potência" e "Frequência", respectivamente.
        Os Subscritos nl, br e cc são referentes a "No Load", "Blocked Rotor" e "C.C", respectivamente.
%}

% No Load

V_nl = 550;
I_nl = 5.8;
P_nl = 754;
F_nl = 60;

% Blocked Rotor

V_br = 123;
I_br = 25;
P_br = 2419;
F_br = 0;

% C.C

V_cc = 15;
I_cc = 25;
F_cc = 0;

%{
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

%}



% Cálculo de R_1

R_1 = (V_cc/I_cc)/2;
fprintf("Resistência de Estator = %.2f \n", R_1);

% Cálculo de R_nl

R_nl = (P_nl/(3*I_nl^2));
fprintf("Resistência Motor a Vazio = %.2f \n", R_nl);

% Cálculo de Z_nl

Z_nl = V_nl/(sqrt(3)*I_nl);
fprintf("Impedância Motor a Vazio = %.2f \n", Z_nl);

% Cálculo de  X_nl

X_nl = sqrt((Z_nl^2)-(R_nl^2));
fprintf("Reatância Motor a Vazio = %.2f \n", X_nl);

% No ensaio de Rotor Bloqueado, considerando X_m >> (R2/s + jX_2) --> escorregamento igual a 1

% Cálculo de R_br

R_br = P_br/(3*I_br^2);
fprintf("Resistência de Rotor Bloqueado = %.3f \n", R_br);

% Cálculo de Z_br

Z_br = V_br/(sqrt(3)*I_br);
fprintf("Impedância de Rotor Bloqueado = %.3f \n",Z_br)

% Cálculo de X_br

X_br = sqrt((Z_br^2)-(R_br^2));
fprintf("Reatância de Rotor Bloqueado = %.3f \n", X_br)

% Cálculo de R_2

% Cálculo de R_2
R_2 = R_br - R_1;
fprintf('Resistência de Rotor = %.3f \n', R_2);

% Cálculo de X_1 e X_2 e X_m

% Considerando (X_1/X_2) = 1

X_1 = X_br/2;
fprintf('Reatância de Disperção de Estator = %.3f \n', X_1);

X_2 = X_br/2;
fprintf('Reatância de Disperção de Rotor = %.3f \n', X_2);

X_m = X_nl - X_1;
fprintf('Reatância de Magnetização = %.3f \n', X_m);

% Cálculo das Indutâncias
% A multiplicação por 1000 se da para deixar as indutâncias em mH

w = 2*pi*60;

L_1 = (X_1/w);
L_2 = (X_2/w);
L_m = (X_m/w);

L_1_tab = L_1*1000;
L_2_tab = L_2*1000;
L_m_tab = L_m*1000;

% Apresentando Dados em Tabela


dados_tabela = table([R_1; R_2; X_1; X_2; L_1_tab; L_2_tab; X_m; L_m_tab], 'RowNames', {'R1', 'R2', 'X1', 'X2', 'L1', 'L2', 'Xm', 'Lm'});
dados_tabela.Properties.VariableNames = {'Valor'};

% Arredondando os valores para duas casas decimais
dados_tabela.Valor = round(dados_tabela.Valor, 2);

% Imprimindo a tabela
disp(dados_tabela);

% Definição de Parametros

polos = 4; % Nº de polos da maquina
freq_nominal = 60; % Frequencia de operação da Maquina

ns = (120/polos)*freq_nominal; % Velocidade Sincrona

V_nominal = 550/sqrt(3); % Tensao Nominal da Máquina Trifasica (Fase - Neutro)

V_th = (V_nominal*X_m)/sqrt((R_1^2)+(X_1+X_m)^2); % Tensao de thevenin

w_s = ns*(2*pi/60); % velocidade em rad;s

n = 1760; % velocidade nominal

s  = (ns-n)/ns; % escorregamento

potencia_nominal = 20*746;
torque_nominal = potencia_nominal / ((n * 2 * pi) / freq_nominal);

fprintf('Torque Nominal = %.3f \n', torque_nominal);

%  2) Obtencao das curvas de Conjugado x Velocidade para a máquina com tensao nominal em N.m

% Inicializacao de vetores de zeros de tamanho 100 e um vetor de velocidade

potencia = zeros(1,100);
torque = zeros(1,100);
w_mecanico_pu = zeros(1,100);
w_mecanico = zeros(1,100);
escorregamento = zeros(1,100); %usado apenas na questao 7
velocidades = 0:1:ns;

% Calculo da Z_th
Z_th = X_m*1j*(R_1+X_1*1j)/(R_1 + (X_1+X_m)*1j);
R_th = real(Z_th);
X_th = imag(Z_th);

Z_1 = R_1 + X_1*1j;

Z_2 = (R_2/s) + X_2*1j;


Z_paralelo = (X_m*1j*(Z_2))/(R_2/s + (X_m + X_2)*1j);

Z_equivalente = (Z_1 + Z_paralelo);

% Calculo da Corrente de Entrada
I_1 = V_nominal/Z_equivalente;

for i = 1:length(velocidades)
    n = velocidades(i);
    s = (ns - n)/ns;
    % Calculo do Torque

    R_count = (R_th+R_2/s)^2;
    X_count = (X_th + X_2)^2;

    torque(i) = (3*V_th^2*R_2/s)/(w_s*(R_count + X_count));

    w_mecanico(i) = (1-s)*ns;

    w_mecanico_pu(i) = w_mecanico(i)/ns;

    escorregamento(i) = s;
end

% Plotando o grafico
figure('Name','Gráfico de Torque x Velocidade','NumberTitle','off')
plot(w_mecanico_pu, torque, 'DisplayName','Conjugado x Velocidade','Color','k','LineWidth', .5);
xlabel('Velocidade [pu]');
ylabel('Torque [N.m]');
title('Conjugado [N.m] vs Velocidade [pu]');
legend('show','Location','southwest');
grid on;
grid minor;
saveas(gcf,'torque_vs_velocidade_q_2.png');




% (3) Obtencao dcurva de Conjugado X Velocidade Mecânica para a máquina alimentada em corrente nominal em N.m
% Definicao de Parametros

% Inicializaca de vetores zerados para o calculo do torque
I_2 = zeros(1,100);
torque_I_1_constante = zeros(1,100);
w_mecanico = zeros(1,100);

i = 1;

for s=0:0.001:1

    I_2(i) = (X_m*1j*I_1/(R_2/s + (X_m + X_2)*1j));

    % Cálculo da Potencia e Velocidade, Nota-se que Torque = Potencia / Velocidade Mecanica

    torque_I_1_constante(i) = 3*abs(I_2(i)^2)*(R_2/(s*w_s));

    w_mecanico(i) = (1-s);

    i = i + 1;

end

% Plotando o gráfico
figure('Name','Gráfico de Torque x Velocidade','NumberTitle','off')
plot(w_mecanico, torque_I_1_constante, 'DisplayName','Conjugado vs Velocidade','Color','k','LineWidth', .5);
xlabel('Velocidade [pu]');
title('Conjugado [N.m] vs Velocidade [pu]');
ylabel('Torque [N.m]');
legend('show','Location','northwest');
grid on;
grid minor;
saveas(gcf,'torque_vs_velocidade_q_3.png');


% (4) – Obteção ds curvas de Conjugado X Velocidade Mecanica para a máquina alimentada com 30 e 15Hz, no modo V/f constante.

% Calculo dos parametros para 60 Hz

% Vale notar que temos a condicao de V/f constante

V_nominal_60 = V_nominal;

polos = 4; % Nº de polos da maquina
freq_nominal = 60; % Frequencia de operação da Máquina
n = 1760; % Velocidade Nominal em rpm

ns = (120/polos)*freq_nominal; % Velocidade Sincrona



w_s = ns*(2*pi/60);

V_th = (V_nominal*X_m)/sqrt((R_1^2)+(X_1+X_m)^2);

Z_th = j*X_m*(R_1+j*X_1)/(R_1+j*(X_1+X_m));
R_th = real(Z_th);
X_th = imag(Z_th);

% Inicializaca de vetores zerados para o calculo do torque
torque_60 = zeros(1,100);
w_mecanico_60 = zeros(1,100);

velocidades_60 = 0:1:ns;


for i = 1:length(velocidades_60)
    n = velocidades(i);
    s = (ns - n)/ns;
    % Cálculo do Torque

    R_count = (R_th+R_2/s)^2;
    X_count = (X_th + X_2)^2;

    torque_60(i) = (3*V_th^2*R_2/s)/(w_s*(R_count + X_count));

    w_mecanico_60(i) = (1-s)*ns;

end

% Calculo dos parametros para 30 Hz

% Vale notar que temos a condicao de V/f constante

V_nominal_30 = V_nominal / 2;

polos = 4; % Nº de polos da máquina
freq_nominal_30 = 30; % Frequência de operação da Máquina
n = 1760; % Velocidade Nominal em rpm

ns_30 = (120/polos)*freq_nominal_30; % Velocidade Síncrona



w_s_30 = ns_30*(2*pi/60);

% Faz-se necessario o calculo de X_1, X_2 e X_m para 30 Hz

% Nota - se que as reatancias sao diretamente proporcionais a frequencia

X_1_30 = X_1/2; 
X_2_30 = X_2/2; 
X_m_30 = X_m/2;


V_th_30 = (V_nominal_30*X_m_30)/sqrt((R_1^2)+(X_1_30+X_m_30)^2);

Z_th_30 = j*X_m_30*(R_1+j*X_1_30)/(R_1+j*(X_1_30+X_m_30));
R_th_30 = real(Z_th_30);
X_th_30 = imag(Z_th_30);

% Inicializaca de vetores zerados para o calculo do torque
torque_30 = zeros(1,100);
w_mecanico_30 = zeros(1,100);

velocidades_30 = 0:1:ns_30;


for i = 1:length(velocidades_30)
    n = velocidades_30(i);
    s = (ns_30 - n)/ns_30;
    % Cálculo do Torque

    R_count_30 = (R_th_30+R_2/s)^2;
    X_count_30 = (X_th_30 + X_2_30)^2;

    torque_30(i) = (3*V_th_30^2*R_2/s)/(w_s_30*(R_count_30 + X_count_30));

    w_mecanico_30(i) = (1-s)*ns_30;

end


% Calculo dos parametros para 15 Hz

% Vale notar que temos a condicao de V/f constante

V_nominal_15 = V_nominal / 4;

polos = 4; % Nº de polos da máquina
freq_nominal_15 = 15; % Frequência de operação da Máquina
n = 1760; % Velocidade Nominal em rpm

ns_15 = (120/polos)*freq_nominal_15; % Velocidade Síncrona



w_s_15 = ns_15*(2*pi/60);

% Faz-se necessario o calculo de X_1, X_2 e X_m para 15 Hz

% Nota - se que as reatancias sao diretamente proporcionais a frequencia

X_1_15 = X_1/4; 
X_2_15 = X_2/4; 
X_m_15 = X_m/4;


V_th_15 = (V_nominal_15*X_m_15)/sqrt((R_1^2)+(X_1_15+X_m_15)^2);


Z_th_15 = j*X_m_15*(R_1+j*X_1_15)/(R_1+j*(X_1_15+X_m_15));
R_th_15 = real(Z_th_15);
X_th_15 = imag(Z_th_15);

torque_15 = zeros(1,100);
w_mecanico_15 = zeros(1,100);

velocidades_15 = 0:1:ns_15;

for i = 1:length(velocidades_15)
    n = velocidades_15(i);
    s = (ns_15 - n)/ns_15;
    % Cálculo do Torque

    R_count_15 = (R_th_15+R_2/s)^2;
    X_count_15 = (X_th_15 + X_2_15)^2;

    torque_15(i) = (3*V_th_15^2*R_2/s)/(w_s_15*(R_count_15 + X_count_15));

    w_mecanico_15(i) = (1-s)*ns_15;

end

% Plotando o gráfico
figure('Name','Gráfico de Torque x Velocidade','NumberTitle','off')
plot(w_mecanico_60, torque_60, 'DisplayName','Conjugado x Velocidade (60 Hz)');
hold on;
plot(w_mecanico_30, torque_30, 'DisplayName','Conjugado x Velocidade (30 Hz)');
hold on;
plot(w_mecanico_15, torque_15, 'DisplayName','Conjugado x Velocidade (15 Hz)');
xlabel('Velocidade [rad/s]');
ylabel('Torque [N.m]');
title('Conjugado [N.m] x Velocidade [rad/s] em 60, 30 e 15 Hz')
legend('show','Location','south');
grid on;
grid minor;
saveas(gcf,'torque_vs_velocidade_q_4.png');



%(5) – Obtenção ds curvas de Conjugado X Velocidade Mecânica para a máquina alimentada em 75 e 90Hz


% Calculo dos parametros para 75 Hz

% Vale notar que temos a condicao de V/f constante NAO eh mais valida

polos = 4; % Nº de polos da máquina
freq_nominal_75 = 75; % Frequência de operação da Máquina
n = 1760; % Velocidade Nominal em rpm

ns_75 = (120/polos)*freq_nominal_75; % Velocidade Síncrona



w_s_75 = ns_75*(2*pi/60);

% Faz-se necessario o calculo de X_1, X_2 e X_m para 75 Hz

% Nota - se que as reatancias sao diretamente proporcionais a frequencia

X_1_75 = X_1 * 1.25; 
X_2_75 = X_2 * 1.25; 
X_m_75 = X_m * 1.25;


V_th_75 = (V_nominal*X_m_75)/sqrt((R_1^2)+(X_1_75+X_m_75)^2);

Z_th_75 = j*X_m_75*(R_1+j*X_1_75)/(R_1+j*(X_1_75+X_m_75));
R_th_75 = real(Z_th_75);
X_th_75 = imag(Z_th_75);

% Inicializaca de vetores zerados para o calculo do torque
torque_75 = zeros(1,100);
w_mecanico_75 = zeros(1,100);

velocidades_75 = 0:1:ns_75;


for i = 1:length(velocidades_75)
    n = velocidades_75(i);
    s = (ns_75 - n)/ns_75;
    % Cálculo do Torque

    R_count_75 = (R_th_75+R_2/s)^2;
    X_count_75 = (X_th_75 + X_2_75)^2;

    torque_75(i) = (3*V_th_75^2*R_2/s)/(w_s_75*(R_count_75 + X_count_75));

    w_mecanico_75(i) = (1-s)*ns_75;

end



% Calculo dos parametros para 90 Hz

% Vale notar que temos a condicao de V/f constante NAO eh mais valida

polos = 4; % Nº de polos da máquina
freq_nominal_90 = 90; % Frequência de operação da Máquina
n = 1760; % Velocidade Nominal em rpm

ns_90 = (120/polos)*freq_nominal_90; % Velocidade Síncrona

w_s_90 = ns_90*(2*pi/60);

% Faz-se necessario o calculo de X_1, X_2 e X_m para 90 Hz

% Nota - se que as reatancias sao diretamente proporcionais a frequencia

X_1_90 = X_1 * 1.5; 
X_2_90 = X_2 * 1.5; 
X_m_90 = X_m * 1.5;

V_th_90 = (V_nominal*X_m_90)/sqrt((R_1^2)+(X_1_90+X_m_90)^2);

Z_th_90 = j*X_m_90*(R_1+j*X_1_90)/(R_1+j*(X_1_90+X_m_90));
R_th_90 = real(Z_th_90);
X_th_90 = imag(Z_th_90);
% Inicializaca de vetores zerados para o calculo do torque
torque_90 = zeros(1,100);
w_mecanico_90 = zeros(1,100);

velocidades_90 = 0:1:ns_90;

for i = 1:length(velocidades_90)
    n = velocidades_90(i);
    s = (ns_90 - n)/ns_90;
    % Cálculo do Torque

    R_count_90 = (R_th_90+R_2/s)^2;
    X_count_90 = (X_th_90 + X_2_90)^2;

    torque_90(i) = (3*V_th_90^2*R_2/s)/(w_s_90*(R_count_90 + X_count_90));

    w_mecanico_90(i) = (1-s)*ns_90;

end


% Plotando o gráfico
figure('Name','Gráfico de Torque x Velocidade','NumberTitle','off')
plot(w_mecanico_60, torque_60, 'DisplayName','Conjugado x Velocidade (60 Hz)');
hold on;
plot(w_mecanico_75, torque_75, 'DisplayName','Conjugado x Velocidade (75 Hz)');
hold on;
plot(w_mecanico_90, torque_90, 'DisplayName','Conjugado x Velocidade (90 Hz)');
xlabel('Velocidade [rad/s]');
ylabel('Torque [N.m]');
title('Conjugado [N.m] x Velocidade [rad/s] em 60, 75 e 90 Hz')
legend('show','Location','northeast');
grid on;
grid minor;
saveas(gcf,'torque_vs_velocidade_q_5.png');

% (6) – Conjugado máximo desenvolvido pela máquina?

[torque_maximo_medido, idx] = max(torque); %extracao do valor maximo do vetor de torque

fprintf('Torque Maximo = %.3f \n', torque_maximo_medido);

torque_maximo_calculado = (3*V_th^2) / (2*w_s*(R_th + sqrt(R_th^2 + (X_th + X_2)^2)));

fprintf('Torque Maximo Calculado = %.3f \n', torque_maximo_calculado);

% (7) – Escorregamento no qual se tem conjugado máximo no eixo da máquina?

s_torque_maximo_medido = escorregamento(idx); % extracao do valor do escorregamento que ocorre o torque maximo

fprintf('Escorregamento Maximo = %.3f \n', s_torque_maximo_medido);

s_torque_maximo_calculado = R_2 / sqrt(R_th^2 + (X_th + X_2)^2);

fprintf('Escorregamento Maximo Calculado = %.3f \n', s_torque_maximo_calculado);


%{
    (8) – Sendo o conjugado percentual a variável do eixo x, a qual deve assumir valores de 0 a 130%.
        8.1 - Fator de potência de entrada
        8.2 - Corrente de estator
        8.3 - Rendimento
        8.4 - Rendimento vezes o fator de potência de entrada

%} 

% Configuracoes iniciais

torque_130 = torque_nominal*1.3;

fprintf('torque = %.3f \n',torque_nominal);

[torque_130_vetor, idx] = min(abs(torque - torque_130)); %calcula a posicao no vetor onde esta o 130 torque


w_130 = velocidades(idx); % encontra a velocidade em que o torque 130 ocorre

fprintf('w_130 = %.3f \n',w_130);

s_130 = (1-(velocidades(idx))/(ns)); %calcula o escorregamento 130

fprintf('torque_130 = %.3f \n', torque_130_vetor)

fprintf('s_130 = %.3f \n',s_130);

% Inicializaca de vetores zerados para o calculo do torque
I_estator = zeros(1,100);
fator_de_potencia = zeros(1,100);

I_rotor = zeros(1,100);

toque_percentual = zeros(1,100);

rendimento = zeros(1,100);

fp_rendimento = zeros(1,100);


i = 1;

for s = 0:0.0001:s_130

    Z_1_item_8= R_1+j*X_1+(j*X_m*(R_2/s+j*X_2))/(R_2/s+j*(X_m+X_2));

    I_1_item_8 = V_nominal / Z_1_item_8; %calcula corrente i1

    phi = angle(I_1_item_8); %calcula o angulo da corrente i1

    I_estator(i) = abs(I_1_item_8);

    fator_de_potencia(i) = cos(phi); % calcula o fator de potencia

    I_rotor(i) = V_th/sqrt((R_2/s + R_th)^2 + (X_2 + X_th)^2);

    toque_percentual(i) = (3 * I_rotor(i)^2 * R_2/(s*w_s))/torque_nominal*100; %com o vetor i_rotor calcula o vetor torque

    pot_entrada = 3*V_nominal*I_estator(i)*cos(phi); %calcula a potencia de entrada da maquina

    pot_saida = 3*I_rotor(i)^2*R_2/s*(1-s); %calcula a potencia de saida 

    rendimento(i) = pot_saida / pot_entrada; %calcula o rendimento

    fp_rendimento(i) = fator_de_potencia(i) * rendimento(i); %multiplica rendimento por fp

    i = i + 1;

end

% 8.1 Grafico Fator de Potencia

figure('Name','Gráficos Diversos','NumberTitle','On')

subplot(2,2,1)

plot(toque_percentual,I_estator, 'DisplayName','I no Estator (A)','Color','k','LineWidth', .4);
ylabel("Corrente [A]");
xlabel('Tensão [%]');
title("Corrente [A] vs Tensão[%]");
legend('show','Location','southeast');
grid on;
grid minor;

subplot(2,2,2)
plot(toque_percentual, fator_de_potencia, 'DisplayName','F.P','Color','k','LineWidth', .4);
ylabel("Fator de Potência [f.p]");
xlabel('Tensão [%]');
title("Fator de Potência vs Tensão[%]");
legend('show','Location','south');
grid on;
grid minor;


subplot(2,2,3)
plot(toque_percentual,rendimento, 'DisplayName','\eta','Color','k','LineWidth', .4);
ylabel("Rendimento \eta");
xlabel('Tensão [%]');
title("\eta vs Tensão[%]");
legend('show','Location','south');
grid on;
grid minor;


subplot(2,2,4)
plot(toque_percentual,fp_rendimento, 'DisplayName','F.P x \eta','Color','k','LineWidth', .4);
ylabel("F.P x \eta");
xlabel('Tensão [%]');
title("F.P x \eta vs Tensão[%]");
legend('show','Location','south');
grid on;
grid minor;
saveas(gcf,'torque_vs_velocidade_q_6.png');


