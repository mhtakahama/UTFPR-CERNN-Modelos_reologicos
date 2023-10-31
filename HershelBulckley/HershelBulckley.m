%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Universidade Tecnologica Federal do Parana (UTFPR) - Campus Curitiba
%Doutorando: Marcos Hiroshi Takahama
%Professor: Cezar Otaviano Ribeiro Negrao
%out 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0 - Organização e leitura de dados
clear all; echo off; close all force; clc; tic; format long; %clear another variables

% Leitor de dados do Excel
% [num_dados,txt_dados,Dados_reologicos] = xlsread('Dados_Graxas.xlsx');
[num_dados,~,~] = xlsread('Dados_Reometro.xlsx');

shear_rate=num_dados(:,1);
eta=num_dados(:,2);
shear_stress=eta.*shear_rate;

%% 1 - Modelo e Fit

HershelBulckley_model=@(cte,x) cte(1)+cte(2).*(x).^cte(3);

% Parâmetros iniciais estimados
tau_0_guess = 50; 
k_guess = 0.1;    
n_guess = 0.5;  

% Parâmetros iniciais para otimização
initial_params = [tau_0_guess, k_guess, n_guess];

% Ajuste da curva
optimized_params = lsqcurvefit(HershelBulckley_model, initial_params, shear_rate, shear_stress);

% Valores otimizados dos parâmetros
tau_0 = optimized_params(1);
k = optimized_params(2);
n = optimized_params(3);
%% 2 - Plots

% Criação de uma curva ajustada usando os parâmetros otimizados
shear_rate_fit = linspace(min(shear_rate), max(shear_rate), 1000);
shear_stress_fit = HershelBulckley_model(optimized_params, shear_rate_fit);

figure
axes('XScale', 'log', 'YScale', 'linear')
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);%Maximiza a janela
set(gcf,'Name',['1 - HershelBulckley model'],'NumberTitle','off');
title(sprintf('HershelBulckley model\n {\\tau_0}= %.2f, k = %.2f, n = %.2f', tau_0, k, n), 'FontSize',30);

hold on
loglog(shear_rate_fit, shear_stress_fit,'-r','LineWidth',3);
hold on
loglog(shear_rate, shear_stress,'*k','LineWidth',1);

xlabel('Shear rate {\gamma} (s^{-1})','FontSize',30);
ylabel('Shear Stress {\tau} (Pa)','FontSize',30);
%    ylabel('Viscosidade {\eta} (Pa.s)','FontSize',30);
legend('Hershel Bulckley fit','Measured points','latex')
ylim([min(shear_rate) max(shear_rate)*1.2])
ylim([min(shear_stress_fit) max(shear_stress_fit)*1.2])
grid on



%% Fim do código
tempo_cdg=toc/60;%Tempo para rodar o codigo
warndlg(sprintf(['Tudo pronto, Tempo de execução: ' num2str(tempo_cdg,2) ' minutos']));
