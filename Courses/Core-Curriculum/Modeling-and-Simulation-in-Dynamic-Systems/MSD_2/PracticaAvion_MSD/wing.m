function J = wing(x,dibujo)
try
%
% wing.m
%
% Model exported on Mar 25 2026, 19:39 by COMSOL 5.2.1.262.
tic

e= x(1);  
a= x(2); 


import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\usu319\CATI\MSD\eNTREGA');

model.label('wing.mph');

model.comments(['sin t' native2unicode(hex2dec({'00' 'ed'}), 'unicode') 'tulo\n\n']);

model.param.set('e', e);
model.param.set('a', num2str(a));

model.modelNode.create('comp1');

model.geom.create('geom1', 2);

model.mesh.create('mesh1', 'geom1');

model.geom('geom1').create('r1', 'Rectangle');
model.geom('geom1').feature('r1').set('size', {'100' '50'});
model.geom('geom1').feature('r1').set('pos', {'0' '0'});
model.geom('geom1').create('e1', 'Ellipse');
model.geom('geom1').feature('e1').set('semiaxes', {'10' 'e'});
model.geom('geom1').feature('e1').set('pos', {'50' '25'});
model.geom('geom1').feature('e1').set('rot', 'a');
model.geom('geom1').create('dif1', 'Difference');
model.geom('geom1').feature('dif1').selection('input2').set({'e1'});
model.geom('geom1').feature('dif1').selection('input').set({'r1'});
model.geom('geom1').run;

model.material.create('mat1', 'Common', 'comp1');
model.material('mat1').propertyGroup('def').func.create('eta', 'Piecewise');
model.material('mat1').propertyGroup('def').func.create('Cp', 'Piecewise');
model.material('mat1').propertyGroup('def').func.create('rho', 'Analytic');
model.material('mat1').propertyGroup('def').func.create('k', 'Piecewise');
model.material('mat1').propertyGroup('def').func.create('cs', 'Analytic');
model.material('mat1').propertyGroup.create('RefractiveIndex', [native2unicode(hex2dec({'00' 'cd'}), 'unicode') 'ndice de refracci' native2unicode(hex2dec({'00' 'f3'}), 'unicode') 'n']);

model.physics.create('spf', 'LaminarFlow', 'geom1');
model.physics('spf').create('out1', 'OutletBoundary', 1);
model.physics('spf').feature('out1').selection.set([4]);
model.physics('spf').create('inl1', 'InletBoundary', 1);
model.physics('spf').feature('inl1').selection.set([1]);

model.mesh('mesh1').autoMeshSize(4);

model.result.table.create('tbl1', 'Table');

model.view('view1').axis.set('abstractviewxscale', '0.1111111119389534');
model.view('view1').axis.set('abstractviewtratio', '0.05222221463918686');
model.view('view1').axis.set('abstractviewlratio', '-0.05000000074505806');
model.view('view1').axis.set('abstractviewyscale', '0.1111111119389534');
model.view('view1').axis.set('abstractviewrratio', '0.05000000074505806');
model.view('view1').axis.set('abstractviewbratio', '-0.05222221463918686');
model.view('view1').axis.set('ymax', '52.5');
model.view('view1').axis.set('xmax', '105');
model.view('view1').axis.set('ymin', '-2.5');
model.view('view1').axis.set('xmin', '-5');

model.material('mat1').label('Air');
model.material('mat1').set('family', 'air');
model.material('mat1').propertyGroup('def').func('eta').set('pieces', {'200.0' '1600.0' '-8.38278E-7+8.35717342E-8*T^1-7.69429583E-11*T^2+4.6437266E-14*T^3-1.06585607E-17*T^4'});
model.material('mat1').propertyGroup('def').func('eta').set('arg', 'T');
model.material('mat1').propertyGroup('def').func('Cp').set('pieces', {'200.0' '1600.0' '1047.63657-0.372589265*T^1+9.45304214E-4*T^2-6.02409443E-7*T^3+1.2858961E-10*T^4'});
model.material('mat1').propertyGroup('def').func('Cp').set('arg', 'T');
model.material('mat1').propertyGroup('def').func('rho').set('dermethod', 'manual');
model.material('mat1').propertyGroup('def').func('rho').set('expr', 'pA*0.02897/8.314/T');
model.material('mat1').propertyGroup('def').func('rho').set('argders', {'pA' 'd(pA*0.02897/8.314/T,pA)'; 'T' 'd(pA*0.02897/8.314/T,T)'});
model.material('mat1').propertyGroup('def').func('rho').set('args', {'pA' 'T'});
model.material('mat1').propertyGroup('def').func('rho').set('plotargs', {'pA' '0' '1'; 'T' '0' '1'});
model.material('mat1').propertyGroup('def').func('k').set('pieces', {'200.0' '1600.0' '-0.00227583562+1.15480022E-4*T^1-7.90252856E-8*T^2+4.11702505E-11*T^3-7.43864331E-15*T^4'});
model.material('mat1').propertyGroup('def').func('k').set('arg', 'T');
model.material('mat1').propertyGroup('def').func('cs').set('dermethod', 'manual');
model.material('mat1').propertyGroup('def').func('cs').set('expr', 'sqrt(1.4*287*T)');
model.material('mat1').propertyGroup('def').func('cs').set('argders', {'T' 'd(sqrt(1.4*287*T),T)'});
model.material('mat1').propertyGroup('def').func('cs').set('args', {'T'});
model.material('mat1').propertyGroup('def').func('cs').set('plotargs', {'T' '0' '1'});
model.material('mat1').propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat1').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat1').propertyGroup('def').set('dynamicviscosity', 'eta(T[1/K])[Pa*s]');
model.material('mat1').propertyGroup('def').set('ratioofspecificheat', '1.4');
model.material('mat1').propertyGroup('def').set('electricconductivity', {'0[S/m]' '0' '0' '0' '0[S/m]' '0' '0' '0' '0[S/m]'});
model.material('mat1').propertyGroup('def').set('heatcapacity', 'Cp(T[1/K])[J/(kg*K)]');
model.material('mat1').propertyGroup('def').set('density', 'rho(pA[1/Pa],T[1/K])[kg/m^3]');
model.material('mat1').propertyGroup('def').set('thermalconductivity', {'k(T[1/K])[W/(m*K)]' '0' '0' '0' 'k(T[1/K])[W/(m*K)]' '0' '0' '0' 'k(T[1/K])[W/(m*K)]'});
model.material('mat1').propertyGroup('def').set('soundspeed', 'cs(T[1/K])[m/s]');
model.material('mat1').propertyGroup('def').addInput('temperature');
model.material('mat1').propertyGroup('def').addInput('pressure');
model.material('mat1').propertyGroup('RefractiveIndex').set('n', '');
model.material('mat1').propertyGroup('RefractiveIndex').set('ki', '');
model.material('mat1').propertyGroup('RefractiveIndex').set('n', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat1').propertyGroup('RefractiveIndex').set('ki', {'0' '0' '0' '0' '0' '0' '0' '0' '0'});

model.physics('spf').prop('PhysicalModelProperty').set('Compressibility', 'CompressibleMALT03');
model.physics('spf').prop('InconsistentStabilization').set('IsotropicDiffusion', '1');
model.physics('spf').feature('out1').set('NormalFlow', '1');
model.physics('spf').feature('inl1').set('U0in', '1e-2*s*(1-s)');

model.mesh('mesh1').run;

model.frame('material1').sorder(1);

model.result.table('tbl1').comments(['Integraci' native2unicode(hex2dec({'00' 'f3'}), 'unicode') 'n de l' native2unicode(hex2dec({'00' 'ed'}), 'unicode') 'neas 1 (spf.T_stressy)']);

model.study.create('std1');
model.study('std1').create('stat', 'Stationary');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').create('d1', 'Direct');
model.sol('sol1').feature('s1').feature.remove('fcDef');

model.result.numerical.create('int1', 'IntLine');
model.result.numerical('int1').selection.set([5 6 7 8]);
model.result.numerical('int1').set('probetag', 'none');
model.result.create('pg1', 'PlotGroup2D');
model.result.create('pg2', 'PlotGroup2D');
model.result('pg1').create('surf1', 'Surface');
model.result('pg1').create('str1', 'Streamline');
model.result('pg2').create('con1', 'Contour');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('s1').feature('fc1').set('initstep', '0.01');
model.sol('sol1').feature('s1').feature('fc1').set('maxiter', '100');
model.sol('sol1').feature('s1').feature('fc1').set('minstep', '1.0E-6');
model.sol('sol1').feature('s1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').runAll;

model.result.numerical('int1').set('descr', {['Tensi' native2unicode(hex2dec({'00' 'f3'}), 'unicode') 'n total, componente y']});
model.result.numerical('int1').set('table', 'tbl1');
model.result.numerical('int1').set('unit', {'N/m'});
model.result.numerical('int1').set('expr', {'spf.T_stressy'});
model.result.numerical('int1').setResult;
model.result('pg1').label('Velocidad (spf)');
model.result('pg1').set('frametype', 'spatial');
model.result('pg1').feature('surf1').label('Superficie');
model.result('pg1').feature('surf1').set('descr', ['N' native2unicode(hex2dec({'00' 'fa'}), 'unicode') 'mero Reynolds de celda']);
model.result('pg1').feature('surf1').set('unit', '1');
model.result('pg1').feature('surf1').set('expr', 'spf.cellRe');
model.result('pg1').feature('surf1').set('resolution', 'normal');
model.result('pg1').feature('str1').set('posmethod', 'uniform');
model.result('pg1').feature('str1').set('udist', '0.01');
model.result('pg1').feature('str1').set('resolution', 'normal');
model.result('pg2').label(['Presi' native2unicode(hex2dec({'00' 'f3'}), 'unicode') 'n (spf)']);
model.result('pg2').set('frametype', 'spatial');
model.result('pg2').feature('con1').label('Curva de nivel');
model.result('pg2').feature('con1').set('descr', ['Presi' native2unicode(hex2dec({'00' 'f3'}), 'unicode') 'n']);
model.result('pg2').feature('con1').set('unit', 'Pa');
model.result('pg2').feature('con1').set('number', '40');
model.result('pg2').feature('con1').set('expr', 'p');
model.result('pg2').feature('con1').set('resolution', 'normal');

out = model;

% J es la portanza
J = model.result.numerical('int1').getReal;
if dibujo == 1
    figure(1)
    clf
    mphplot(model,'pg1')
    title('Diseño actual')
end 
toc 
catch 
    J = 1e9; 
end 
end 
