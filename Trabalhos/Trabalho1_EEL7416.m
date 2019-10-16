%Universidade Federal de Santa Catarina%
%Centro Tecnol�gico%
%Departamento de Engenharia El�trica e Eletr�nica%
%EEL7416 - Introdu��o � Codifica��o%
%Professor: Bartolomeu Uchoa%
%Aluno: Gustavo Simas da Silva%
%Setembro 2019%

%TRABALHO 1 - SIMULA��O C�DIGOS CORRETORES DE ERRO
%Obs: dependendo dos valores de L (e da configura��o do computador)
%simula��o pode levar um tempo consider�vel para rodar

%FUNCAO MAIN
function main = main()

format long

p = [0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1]; %vetor de probabilidades a serem testadas
L1 = 100; %Num blocos 1
L2 = 1000; %Num blocos 2
L3 = 10000; %Num blocos 3

f1 = figure('Name', 'Simula��o L = 100');
plotall(p, L1) %funcao para plotar todos os gr�ficos

f2 = figure('Name', 'Simula��o L = 1000');
plotall(p, L2) %funcao para plotar todos os gr�ficos

f3 = figure('Name', 'Simula��o L = 10000');
plotall(p, L3) %funcao para plotar todos os gr�ficos

end


%-----FUNCOES AUXILIARES----------


%FUNCAO PROB ERRO REPETICAO TEORICO
function proberro = ProbErroRepeticao(p)
    proberro = 1 - (((1-p).^7) + 7.*p.*((1-p).^6) + nchoosek(7,2).*(p.^2).*((1-p).^5) + nchoosek(7,3).*(p.^3).*((1-p).^4));
end

%FUNCAO PROB ERRO HAMMING TEORICO
function proberro = ProbErroHamming(p)
    proberro = 1 - (((1-p).^7) + 7.*p.*((1-p).^6));
end

%FUNCAO PROB ERRO TRANSM TEORICO
function proberro = ProbErroTransm(p)
    proberro = 1 - ((1-p).^7);
end

%FUNCAO CRIAR MENSAGEM
%Cria palavra-c�digo com vetor de bits aleat�rios e adiciona ru�do bin�rio
%Verifica a taxa de c�digo k para utilizar correta matriz geradora G
function [palavracod, palavracodruido]  = Mensagem(k,p)
    u = round(rand(1, k));
    if k == 1
        G = [1 1 1 1 1 1 1];
        v = u*G;
    elseif k == 4
        G = [1 1 0 1; 1 0 1 1; 1 0 0 0; 0 1 1 1; 0 1 0 0; 0 0 1 0; 0 0 0 1];
        v = u*G';
        v = rem(v,2);
    else
        G = [1];
        v = u*G;
    end
    palavracod = v;
    e = round(rand(1,7) - 0.5 + p);
    v = xor(v,e);
    palavracodruido = v;
end

%FUNCAO REPETICAO
%Calcula probabilidade de erro para c�digo repeticao taxa 1/7
function proberro = repeticao(k, p, L)
    erro = 0;
    for i = 1:L
        [palavracod, palavracodruido]  = Mensagem(k,p);
        numnaozeros = nnz(palavracodruido);
        numzeros = length(palavracodruido) - numnaozeros;
        if numnaozeros > numzeros
            word = ones(1,7);
        else
            word = zeros(1,7);
        end
        
        if ~isequal(palavracod,word)
            erro = erro + 1;
        end
    end
    proberro = erro/L;
end


%FUNCAO HAMMING
%Calcula probabilidade de erro para c�digo hamming taxa 4/7
function proberro = hamming(k, p, L)
    erro = 0;
    for i = 1:L
        [palavracod, palavracodruido]  = Mensagem(k,p);
        dist_min = k + 1;
        
        M = 0:15;
        Mstr  = dec2bin(M,3);   % array char decimal para binario
        Mcell = cellstr(dec2bin(M,3)).'; % celula array
        Mnum  = dec2bin(M,3)-'0';   % array numerico
        
        G = [1 1 0 1; 1 0 1 1; 1 0 0 0; 0 1 1 1; 0 1 0 0; 0 0 1 0; 0 0 0 1];
        
        for j = 1:length(Mnum)
            v = Mnum(j,:)*G';
            v = rem(v,2);            

            dif = v - palavracodruido;
            dist = nnz(dif);
            if dist < dist_min
                dist_min = dist;
                word = v;
            end
        end
        if ~isequal(palavracod,word)
            erro = erro + 1;
        end
    end
    proberro = erro/L;
end


%FUNCAO 7/7
%Calcula probabilidade de erro para c�digo "transmissao" (nomenclatura pr�pria) taxa 7/7
function proberro = transm(k, p, L)
    erro = 0;
    for i = 1:L
        [palavracod, palavracodruido]  = Mensagem(k,p);
        word = palavracodruido;
        if ~isequal(palavracod,word)
            erro = erro + 1;
         end
    end
    proberro = erro/L;
end

%FUNCAO PLOT
%Utiliza de funcoes anteriores para calculo das probabilidades
%Plota todos os gr�ficos correspondentes
function plotall(p, L)
    
    for i = 1:length(p)
        probrep(i) = repeticao(1, p(i), L);
        probham(i) = hamming(4, p(i), L);
        probtransm(i) = transm(7, p(i), L);
    end
    
    rep_teor = ProbErroRepeticao(p);
    ham_teor = ProbErroHamming(p);
    trans_teor = ProbErroTransm(p);

    %Plots Te�ricos
    plot(p, rep_teor, 'r');
    hold on;
    plot(p, ham_teor, 'black');
    hold on;
    plot(p, trans_teor, 'b');
    hold on;
    
    %Plots Pr�ticos
    plot(p,probrep,'r*');
    hold on;
    plot(p,probham,'black*');
    hold on;
    plot(p,probtransm,'b*');
    hold on
    
    %Configuracoes de gr�fico
    title('Resultado de simula��o');
    xlabel('Pe (probabilidade de erro)'); 
    ylabel('p (probabilidade de transi��o BSC)');
    legend({'Repeti��o','Hamming', '"Transmiss�o"'},'Location','northwest');
    grid on;
    grid minor;
    
end