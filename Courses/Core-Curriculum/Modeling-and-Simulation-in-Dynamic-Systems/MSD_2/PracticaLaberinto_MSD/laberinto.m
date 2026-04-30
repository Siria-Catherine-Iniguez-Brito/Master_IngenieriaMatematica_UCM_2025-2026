% Cargamos las bibliotecas de comonl 
import com.comsol.model.*
import com.comsol.model.util.*

% Creamos la estructura del model 
model = ModelUtil.create('Model');

% Creamos la componente 1 
model.modelNode.create('comp1');

% Creamos la geometria 
model.geom.create('geom1', 2);
model.geom('geom1').create('r1', 'Rectangle');
model.geom('geom1').feature('r1').set('size', {'2.2' '1.3'});
model.geom('geom1').feature('r1').set('pos', {'-1.05' '-0.45'});
model.geom('geom1').create('r2', 'Rectangle');
model.geom('geom1').feature('r2').set('size', {'0.1' '0.65'});
model.geom('geom1').feature('r2').set('pos', {'-0.7' '-0.45'});
model.geom('geom1').create('r3', 'Rectangle');
model.geom('geom1').feature('r3').set('size', {'0.25' '0.8'});
model.geom('geom1').feature('r3').set('pos', {'-0.3' '0.05'});
model.geom('geom1').create('r4', 'Rectangle');
model.geom('geom1').feature('r4').set('size', {'0.65' '0.1'});
model.geom('geom1').feature('r4').set('pos', {'-0.05' '0.4'});
model.geom('geom1').create('sq1', 'Square');
model.geom('geom1').feature('sq1').set('size', '0.25');
model.geom('geom1').feature('sq1').set('pos', {'0.55' '0.6'});
model.geom('geom1').create('sq2', 'Square');
model.geom('geom1').feature('sq2').set('size', '0.3');
model.geom('geom1').feature('sq2').set('pos', {'0.8' '0.1'});
model.geom('geom1').create('r5', 'Rectangle');
model.geom('geom1').feature('r5').set('size', {'0.2' '0.5'});
model.geom('geom1').feature('r5').set('pos', {'0.5' '-0.45'});
model.geom('geom1').create('r6', 'Rectangle');
model.geom('geom1').feature('r6').set('size', {'0.6' '0.1'});
model.geom('geom1').feature('r6').set('pos', {'-0.1' '-0.15'});
model.geom('geom1').create('dif1', 'Difference');
model.geom('geom1').feature('dif1').selection('input2').set({'r2' 'r3' 'r4' 'r5' 'r6' 'sq1' 'sq2'});
model.geom('geom1').feature('dif1').selection('input').set({'r1'});
model.geom('geom1').create('c1', 'Circle');
model.geom('geom1').feature('c1').set('r', '0.05');
model.geom('geom1').feature('c1').set('pos', {'-0.9' '-0.3'});
model.geom('geom1').create('c2', 'Circle');
model.geom('geom1').feature('c2').set('r', '0.05');
model.geom('geom1').feature('c2').set('pos', {'0.05' '0.75'});
model.geom('geom1').create('dif2', 'Difference');
model.geom('geom1').feature('dif2').selection('input2').set({'c1' 'c2'});
model.geom('geom1').feature('dif2').selection('input').set({'dif1'});
model.geom('geom1').run;

figure(1)
clf
mphgeom(model,'geom1')
grid on 
box on 
title('Mi laberinto')
saveas(gca,'migeom','jpg')


% Creamos la malla 
model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').run;

figure(2)
mphmesh(model,'mesh1')
grid on 
box on 
title('Malla')
saveas(gca,'mimalla','pdf')



% Creamos la fisica
model.physics.create('hteq', 'HeatEquation', 'geom1');
model.physics('hteq').create('dir1', 'DirichletBoundary', 1);
model.physics('hteq').feature('dir1').selection.set([33 34 35 36]);
model.physics('hteq').create('dir2', 'DirichletBoundary', 1);
model.physics('hteq').feature('dir2').selection.set([37 38 39 40]);

model.physics('hteq').feature('hteq1').set('f', '0');
model.physics('hteq').feature('dir1').set('r', '1');
model.physics('hteq').feature('dir1').label('Juanito');
model.physics('hteq').feature('dir2').set('r', '-1');
model.physics('hteq').feature('dir2').label('Casa');



% Creamos el estudio estacionario
model.study.create('std1');
model.study('std1').create('stat', 'Stationary');

% Creamos la solucion y resolvemos 

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').feature.remove('fcDef');
 

% Creamos las salidas 
model.result.create('pg1', 'PlotGroup2D');
model.result.create('pg2', 'PlotGroup2D');
model.result('pg1').create('surf1', 'Surface');
model.result('pg2').create('str1', 'Streamline');
model.result('pg2').feature('str1').selection.set([33 34 35 36]);
model.result.export.create('plot1', 'Plot');

model.sol('sol1').attach('std1');
model.sol('sol1').runAll;

model.result('pg1').feature('surf1').set('resolution', 'normal');
model.result('pg2').label('caminos');
model.result('pg2').feature('str1').set('selnumber', '100');
model.result('pg2').feature('str1').set('resolution', 'normal');
model.result.export('plot1').set('plotgroup', 'pg2');
model.result.export('plot1').set('plot', 'str1');
model.result.export('plot1').set('filename', 'C:\Users\usu319\CATI\MSD\EntregaLaberinto\camino.txt');

figure(3)
subplot(2,1,1)
mphplot(model,'pg1')
title('Temperatura ')
grid on 
box on 
subplot(2,1,2)
mphplot(model,'pg2')
title('Caminos ')
grid on 
box on 
saveas(gca,'miscaminos','pdf')


% =========================================================================
% POST-PROCESSING: Extract the Shortest Streamline from Exported Data
% =========================================================================

% Load streamline data exported from COMSOL
% Format: columns are [x, y, streamlineID]
aa = load('camino.txt');
 
% Initialize shortest length
longm = inf;

% Get the list of unique streamline identifiers
bb = sort(unique(aa(:,3)));  % streamline IDs

% -------------------------------------------------------------------------
% LOOP THROUGH STREAMLINES TO FIND THE SHORTEST ONE THAT REACHES THE GOAL
% -------------------------------------------------------------------------
for ii = 1:length(bb)
    % Extract x and y coordinates of streamline number ii
    uu = aa(aa(:,3) == bb(ii), 1);  % x-coordinates
    vv = aa(aa(:,3) == bb(ii), 2);  % y-coordinates

    % Filter only those that start near the final point (i.e., goal reached)
    if (uu(1) > -0.03) & (uu(1) < 0.3) & (vv(1) >0.6 )& (vv(1)<0.9)
        % Compute total length of the streamline
        lengv = 0;
        for jj = 1:length(uu)-1
            lengv = lengv + sqrt((uu(jj)-uu(jj+1))^2 + (vv(jj)-vv(jj+1))^2);
        end

        % Update if this streamline is the shortest so far
        if lengv < longm
            longm = lengv;
            uum = uu;  % store shortest x
            vvm = vv;  % store shortest y
        end
    end
end


% =========================================================================
% PLOT ALL VALID STREAMLINES AND HIGHLIGHT THE SHORTEST PATH
% =========================================================================

vsl = 0;  % Counter for valid streamlines (that reach the goal)

figure(5)
clf
axes('fontsize',14)
hold on

% Plot geometry again
mphgeom(model)

% Loop to plot all streamlines that start near the final point
for ii = 1:length(bb)
    uu = aa(aa(:,3) == bb(ii), 1);  % x
    vv = aa(aa(:,3) == bb(ii), 2);  % y

    if (uu(1) > -0.03) & (uu(1) < 0.3) & (vv(1) >0.6 )& (vv(1)<0.9)
        % Compute length for info (optional)
        lengv(ii) = 0;
        for jj = 1:length(uu)-1
            lengv(ii) = lengv(ii) + sqrt((uu(jj)-uu(jj+1))^2 + (vv(jj)-vv(jj+1))^2);
        end

        vsl = vsl + 1;
        plot(uu, vv, 'y', 'linewidth', 1);  % plot in gray
    end
end

% Highlight the shortest path in bold black
plot(uum, vvm, 'k', 'linewidth', 3)

% Add title and formatting
title('Shortest Path via Heat Equation Streamlines')
axis tight





out = model;
return