%==========================================================================   
%==========================================================================                                                                          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%                                                                         % 
%       UNIVERSIDADE FEDERAL DE GOI�S                                     %  
%       IMTec - UFG  - PPGMO                                              %
%                                                                         %
%       IMPLEMENTA�AO DA TECNICA DE OTIMIZA�AO "SIMULATED ANNEALING"      %
%                                       
%                                                     
%                       Romes Antonio Borges                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                          
%==========================================================================
%==========================================================================

function [fbest, xbest, ncalls, iaceit, ibest] = simannealing(evalcosf, ...
    x0, xlower, xupper, starttemp,stoptemp, ntemp)

    %======================================================================
    %               Par�metros de entrada
    %======================================================================
    %evalcosf = fun��o objetivo
    %x0 = Vetor dos par�metros de projeto (configura��o inicial)
    %xlower = limite inferior das vari�veis de projeto
    %xupper = limite superior das vari�veis de projeto 
    %starttemp = Temperatura incial � o desvio padr�o da perturba��o 
                %rand�mica usada inicialmente deve ser maior que a m�xima
                %dist�ncia esperada entre o in�cio e o ponto de m�nimo.
    %stoptemp = %� o desvio padr�o final. Ele deve ter a magnitude da 
                %precis�o esperada na localiza��o do melhor ponto
    %ntemp = Quantidade de temperaturas
    %======================================================================
    %======================================================================
    
    
    %======================================================================
    %               Par�metros de resposta
    %======================================================================
    %fbest = melhor valor da fun��o objetivo
    %xbest = melhor ponto encontrado
    %ncalls = n�mero de avalia��es da fun��o objetivo
    %iaceit = n�mero de pontos aceitos durante pelo crit�rio de Metropolis
    %ibest = n�mero de pontos melhorados
    %======================================================================
    %======================================================================
    
    
    %======================================================================
    %               Par�metros de execu��o pr�-estabelecidos
    %======================================================================
    niters = 300;   %Quantidade de itera��oes para cada temperatura
    setback = 10;   %Volta a itera��o se necess�rio
    nepsilon = 5;   %N�mero de temperaturas consecutivas onde o crit�rio de
                    %converg�ncia deve ser satisfeito
    
    maxcalls = 3000;     %Numero limite de avalia��es da fun��o objetivo
    fquit = 1.e-3;       %Toler�ncia considerada para a fun��o minimizada
    kb = 1.e-6;          %Constante de Boltzmann (tdesvio)
    %======================================================================
    %======================================================================
    
    nvars = length(x0);                        %Quantidade de vari�veis de projeto           
    rt = exp(log(stoptemp/starttemp)/(ntemp-1)); %coeficiente de
                                                %atualiza��o da temperatura
    %Configura��o inicial                                             
    x = x0;
    xbest = x0;      
    fbest = evalcosf(xbest);
    E0 = fbest;
    ncalls = 1;
    
    ibest = 1;
    bestx(1,:) = xbest;
    bestfunction(1) = fbest;

    iaceit = 1;     
    temp = starttemp;
   
        
    for itemp = 1:1:ntemp   %Loop de redu��o da temperatura
        %disp(['TEMPERATURA: ',num2str(itemp)])
              
        jj = 1;
        while jj <= niters %Loop para cada temperatura
            %disp(['       Ponto: ',num2str(jj)])
                
            %Nova configura��o
            xreturn = shake(nvars,x,temp, xlower, xupper);
            ncalls = ncalls+1;
                
            E1 = evalcosf(xreturn); 
            dE = E1-E0; %varia��o da fun��o objetivo (fun��o energia)
                
            if dE <= 0
                %Teste para aumentar o n�mero de buscas caso haja melhora 
                %na fun��o objetivo na itera��o jj da temperatura itemp.
                jj = max(0,jj-setback);
                
                x = xreturn; %Aceita a nova configura��o
                E0 = E1;
                if E1<fbest
                    fbest = E1;
                    xbest = xreturn; %Atualiza o ponto �timo
                    ibest = ibest+1;
                    
                    bestx(ibest,:) = xbest(1,:);
                    bestfunction(ibest) = fbest;
                end
                 
            elseif dE > 0
                pfval = exp((-dE)/kb*temp);
                prand = rand;
                if prand < pfval 
                    iaceit = iaceit+1;                   
                    x = xreturn; %Aceite a configura��o
                    E0 = E1;
                end
            end
            
            jj = jj+1;
            
            %==============================================================
            %          Crit�rios de converg�ncia
            %==============================================================
            if(ibest>nepsilon)
                df = bestfunction(ibest-nepsilon)-bestfunction(ibest);
                if df <= fquit        %Atendida a toler�ncia
                    %disp('Parada pela toler�ncia da fun��o objetivo')
                    return
                end
            end
            
            if ncalls >= maxcalls %n�mero m�ximo de avalia��es da f. obj.
                %disp('Parada pelo n�mero de pontos visitados')
                return
            end
            %==============================================================
            %==============================================================
        end             
                                 
        temp=rt*temp; %Atuali��o da temperatura
        
    end
    
end

