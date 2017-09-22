%% Pruebas del clasificador de machine learning
% Es el archivo que realizará los test y la eficacia del clasificador
% A partir de un archivo con el conjunto completo clasificado, se procede a 
% realizar los test de eficacia. Estos test pueden ayudar a saber si el
% clasificador realiza correctamente su trabajo.
% Al final muestra una matriz de resultados segú la clasificación del
% experto y del software.

%% Ajuste de parámetros iniciales
clc; clear all; close all;

pathPrincipal='/home/usuario/ml/clasDefectos2/'; 
pathResultados=strcat(pathPrincipal,'output/clasDefPrewitt/');


%% valores experimentos
totalPruebas=100;


% * Leer el archivo principal.
% * Leer los valores de proporcion de los conjuntos.
% * Leer tabla del archivo conjunto principal.
% * Tomando el set principal, crear en forma aleatoria las filas del test, seleccionando 
% los valores.
% * Tomando el set principal, crear el set de training.
% Con ambos conjuntos, realizar un ciclo que clasifique y luego anote las
% buenas clasificaciones y las malas clasificaicones, con el fin de conocer
% la eficacia
 
 %% Parametros de entrada en fomato .csv

%% Conjunto general de entrenamiento 
nombreArchivoSetCompleto='aCSDefCCCF.csv';
 
 %Leer las 
 nombreArchivoTraining='aTSDefCCCF.csv';
 nombreArchivoTest='aTTDefCCCF.csv';
 nombreArchivoScreen='SCDefCCCF.txt'; 

 
%
formatSpec='%s%f%f%s';

fileHandlerTraining=strcat(pathResultados,nombreArchivoTraining); %handle para conjunto de entrenamiento
fileHandlerTest=strcat(pathResultados,nombreArchivoTest); %handle para conjunto de prueba
fileHandlerDiary=strcat(pathResultados,nombreArchivoScreen);

ETIQUETA_EXPERTO=4;
CARACTERISTICA1=2;
CARACTERISTICA2=3;

%% Apertura del diario de pantallas
diary(fileHandlerDiary)

%% Ingresar parametros
proporcionTraining=input('INGRESE EL PORCENTAGE PARA TRAINING:');

%% Definición a cero de las variables promedio
    acumuladoPrecision=0.0;
    acumuladoExactitud=0.0;
    acumuladoSensibilidad=0.0;
    acumuladoEspecificidad=0.0;

    promedioPrecision=0.0;
    promedioExactitud=0.0;
    promedioSensibilidad=0.0;
    promedioEspecificidad=0.0;

%% Pruebas
% bucle para repetir pruebas
for(prueba=1:1:totalPruebas)
%% 
fprintf('-----------------------------------\n');
fprintf('PRUEBA # %i \n',prueba);
fprintf('-----------------------------------\n');
dividirCDef( proporcionTraining, pathPrincipal, pathResultados, nombreArchivoSetCompleto, nombreArchivoTraining, nombreArchivoTest);


%% Carga del dataset de entrenamiento
% se cargan los datos en una tabla
tablaDSTraining = readtable(fileHandlerTraining,'Delimiter',',','Format',formatSpec);

%se cargan las etiquetas de clasificacion, el lugar 13 corresponde a la
%etiqueta de clasificacion de MANCHAS
tablaDSTrainingClasificacion=tablaDSTraining(:,ETIQUETA_EXPERTO);

% se cargan las caracteristicas que alimentaran al clasificador, el lugar
% 2 TOTAL DE PIXELES DE MANCHAS, 3 TOTAL DE MANCHAS
tablaDSTrainingCaracteristicas=tablaDSTraining(:,CARACTERISTICA1:CARACTERISTICA2);


%% Conversion de tablas a array cell
% Con el fin de ingresar al clasificador se realizan las conversiones de
% tipo
arrayTrainingClasificacion=table2cell(tablaDSTrainingClasificacion);


%Conversion de tabla a array y de array a matriz
arrayTrainingCaracteristicas=table2array(tablaDSTrainingCaracteristicas);


%% Entrenamiento del clasificador
% Se alimenta al clasficador con caracteristicas y las etiquetas para las
% mismas
fprintf('Entrenando clasificador SVM \n');
Clasificador = fitcsvm(arrayTrainingCaracteristicas,arrayTrainingClasificacion);

%% Dividir archivos



%% --- INICIO PRINCIPAL DEL CLASIFICADOR ---
% Se levanta en una tabla el conjunto de datos a clasificar
tablaDSTest = readtable(fileHandlerTest,'Delimiter',',','Format',formatSpec);


% Se obtiene la caracteristica para comparar. 
% Posicion 2 TOTAL DE PIXELES DE MANCHAS, 3 TOTAL DE MANCHAS
tablaDSTestComparar=tablaDSTest(:,CARACTERISTICA1:CARACTERISTICA2);
arrayTest=table2array(tablaDSTestComparar);

%% Definicion de variables a cero
    TP=0;
    TN=0;    
    FP=0;
    FN=0;
    
    precision=0.0;
    exactitud=0.0;
    sensibilidad=0.0;
    especificidad=0.0;

%% Definicion de la matriz de resultados
matrizResultados=zeros(2,2);
%% Recorrer archivo
indiceTest=1;
for indiceTest=1:size(arrayTest)
    %% seleccion del objeto a comparar
    objetoComparar = arrayTest(indiceTest,1:2); %objeto a comparar
    nombreDelaImagenComparar=char(table2array(tablaDSTest(indiceTest,1)));
    etiquetaExperto=char(table2array(tablaDSTest(indiceTest,ETIQUETA_EXPERTO)));
    
    %% Ejecucion de prediccion
    clasificacionObjeto = predict(Clasificador,objetoComparar);
    
    %% Presentacion de Resultados        
    % ---------------------------------------------------------------
        filaMatriz=1;
        columnaMatriz=1;
        % la clasificacion del software va en columnas
        switch char(clasificacionObjeto(1))
            case 'MANCHADO'
                columnaMatriz=1;
            case 'NO MANCHADO'
                columnaMatriz=2;                 
        end
        
        % la clasificacion del experto va en filas
        switch etiquetaExperto
            case 'MANCHADO'
                filaMatriz=1;
            case 'NO MANCHADO'
                filaMatriz=2;                
        end
        % --------------------------------------------------------------

    matrizResultados(filaMatriz,columnaMatriz)=matrizResultados(filaMatriz,columnaMatriz)+1;        
    if(strcmp(etiquetaExperto,clasificacionObjeto(1)))

    else
        fprintf('%s, *totalPixelesManchas = %f, totalManchas = %f, ',nombreDelaImagenComparar, double(objetoComparar(1)), double(objetoComparar(2)));        

        fprintf(',cs=> %s ',char(clasificacionObjeto(1)));
        fprintf(',ce=> %s, \n',etiquetaExperto);        
%        fprintf(' NO IGUALES \n');
    end%comparacion
    
end %fin de archivo

%% --- FIN PRINCIPAL DEL CLASIFICADOR    ---

fprintf('Resultados \n');
fprintf('-----------\n');

%% Mostrar resultados de la matriz
[totalFilas, totalColumnas]=size(matrizResultados);
    fprintf(' clas.software columnas                     |\n');
    fprintf(' MANCHADO |NO MANCHADO| clas.experto filas|\n');
for(filas=1:1:totalFilas)
    for(columnas=1:1:totalColumnas)
        fprintf('%10i|',matrizResultados(filas,columnas));
    end%for

    switch filas
        case 1
            fprintf(' MANCHADO        |');
        case 2
            fprintf(' NO MANCHADO     |');
    end    
    fprintf('\n');           
end %end for

%% Calcular resultados parciales
    TP=matrizResultados(1,1);
    TN=matrizResultados(2,2);    
    FP=matrizResultados(2,1);
    FN=matrizResultados(1,2);

    
    precision=TP/(TP+FP);
    exactitud=(TP+TN)/(TP+TN+FP+FN);
    sensibilidad=TP/(TP+FN);
    especificidad=TN/(TN+FP);

    acumuladoPrecision=acumuladoPrecision+precision;
    acumuladoExactitud=acumuladoExactitud+exactitud;
    acumuladoSensibilidad=acumuladoSensibilidad+sensibilidad;
    acumuladoEspecificidad=acumuladoEspecificidad+especificidad;


    fprintf('PRUEBA %i-> precision=%f, exactitud=%f,sensibilidad=%f especificidad=%f\n', prueba,precision, exactitud, sensibilidad, especificidad);
    fprintf('APrecision=%f, AExactitud=%f, ASensibilidad=%f AEspecificidad=%f\n', acumuladoPrecision, acumuladoExactitud, acumuladoSensibilidad, acumuladoEspecificidad);    

    
end% final de las pruebas


promedioPrecision=acumuladoPrecision/totalPruebas;
promedioExactitud=acumuladoExactitud/totalPruebas;    
promedioSensibilidad=acumuladoSensibilidad/totalPruebas;
promedioEspecificidad=acumuladoEspecificidad/totalPruebas;
fprintf('--------------------------------\n');
fprintf('PROPORCION: %f-%f RESULTADO PROMEDIO EN %i PRUEBAS\n',proporcionTraining,(100-proporcionTraining),totalPruebas);
fprintf('--------------------------------\n');    
fprintf('APrecision=%f, AExactitud=%f, ASensibilidad=%f AEspecificidad=%f\n', acumuladoPrecision, acumuladoExactitud,acumuladoSensibilidad, acumuladoEspecificidad);
    
fprintf('precision=%f, exactitud=%f, sensibilidad=%f especificidad=%f\n', promedioPrecision, promedioExactitud, promedioSensibilidad, promedioEspecificidad);

diary off