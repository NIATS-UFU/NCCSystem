function [emgFilt, thVector] = GetEMGOnSet(sEmg,Fs,T0,T1,k_noise,FcFiltEnv,nFiltEnv,nDPth)
%
% Retorna vetor com limiares (OnSets - definem pacotes de atividade) no
% sinal EMG enviado.
%
%Como chamar esta fun��o (para abrir a GUI):
%
% ===> CHAMADA desta fun��o ==> 
%
%      [emgFilt, thVector] = GetEMGOnSet(sEmg,Fs,T0,T1,k_noise,FcFiltEnv,nFiltEnv,nDPth); 
%
%   Par�metros de entrada
%      sEmg: vetor COLUNA con sinal EMG a ser processado.
%      Fs: frequencia de amostragem do sinal
%      T0,T1: intervalo (em MiliSegundos) do sinal de refer�ncia (o que n�o � sinal)
%      k_noise: constante para desvio padr�o do ru�do do sinal de refer�ncia (1 ou 2)
%      FcFiltEnv: Frequencia de corte do filtro de suaviza��o do envelope.
%      nFiltEnv: Ordem do filtro de suaviza��o do envelope.
%      nDPth: quantidade de desvios padr�o para limiar de atividade no
%      envelope.
%
%    Retorno:
%      emgFilt: O sinal EMG FILTRADO pela t�cnica de Oliveira et al. 
%      thVector: Vetor com OnSets da atividade contr�til. � um vetor de 
%                limiares. 
%                Nas �reas com atividade EMG detectada, os elementos do 
%                vetor ser�o DIFERENTES DE ZERO. 
%                Onde n�o houver sinal EMG (OU onde n�o for o sinal desejado), 
%                os elementos ser�o iguais ZERO...
%como calcular os on-Sets da atividade EMG
%1 - Definir uma regi�o do sinal com irforma��o distinta da desejada.
%    Neste caso, o sinal base pode ser ru�do ou mesmo atividade EMG base.
%    Quando houver resist�ncia ao estiramente teremos aumento da atividade
%    EMG. Assim, deve-se marcar como trecho de refer�ncia um trecho fora da
%    fase de estiramento/recupera��o.
%    O Usu�rio define isso nos controles T0(milisegundos) e T1(milisegundos)
x1 = 1 + round((T0/1000)*Fs);
x2 = 1 + round((T1/1000)*Fs);

%cte_noise: valor da constante de multiplica��o para o desvio padr�o do reuido da
%janela de refer�ncia

%antes, eliminar qualquer n�vel DC - afeta o limiar
sEmg = sEmg - mean(sEmg);

%Aplicar filtro (Andrade et al.)
[emgFilt,DenoisedIMFs,IMFs,NN] = ss_filtEMD(sEmg',x1,x2,k_noise);
%calcular o emvelope do sinal EMG pela transformada de Hilbert
envSig = abs(hilbert(emgFilt));
%suavizar o envelope do sinal conforme definido pelo usu�rio
[envFilt] = m_LPButterworth(envSig,FcFiltEnv,nFiltEnv,Fs);
%calcular limiar conforme nro DPs definidos pelo usu�rio
th = mean(envSig(x1:x2)) + nDPth*std(envSig(x1:x2));
tt = find(envFilt<th); %localizar pontos abaixo do limiar
thVector = envFilt;
thVector(tt)=0; %Zerar todos os pontos do envelope filtrado abaixo do limiar
thVector(x1:x2) = 0; %ignorar qualquer detec��o no intervalo de refer�ncia (de x1 a x2)

