clear all
close all
clc

cd('C:\Users\dhstuart\Dropbox\CLTC\LED life testing');
% [a,b,c] = xlsread('Copy of LED test lab lamp location sheet5.xlsx','Sheet1');
% [d,e,f] = xlsread('Copy of LED test lab lamp location sheet5.xlsx','orientation');
% [g,h,k] = xlsread('Copy of LED test lab lamp location sheet5.xlsx','housing');
% [l,m,n] = xlsread('Copy of LED test lab lamp location sheet5.xlsx','product key');

[a,b,c] = xlsread('lamp location and parameters.xlsx','location');
[d,e,f] = xlsread('lamp location and parameters.xlsx','orientation');
[g,h,k] = xlsread('lamp location and parameters.xlsx','housing');
[l,m,n] = xlsread('lamp location and parameters.xlsx','product key');
[o,p,q] = xlsread('lamp location and parameters.xlsx','dimming');
layout = c(2:65,4:13);
orientation_temp = e(2:65,4:13);
housing_temp = k(2:65,4:13);
dimming_temp = q(2:65,4:13);
%% --------parse--------
dum = 0;
for i = 1:size(layout,1)
    for j = 1:size(layout,2)
        dum = dum+1;
        
        temp_product = str2num(layout{i,j}(1:2));
        if isempty(temp_product)
            product(dum) = NaN;
            sample(dum) = NaN;
        else
            product(dum) = temp_product;
            sample(dum) = str2num(layout{i,j}(4:5));
        end
        rack(dum) = c{i+1,1};
        branch(dum) = c{i+1,2};
        socket(dum) = j;
        orientation{dum} = orientation_temp{i,j};
        if ischar(housing_temp{i,j})
            housing(dum) = NaN;
        else
            housing(dum) = housing_temp{i,j};
        end
        if ischar(dimming_temp{i,j})
            dimming(dum) = NaN;
        else
            dimming(dum) = dimming_temp{i,j};
        end
    end
end

rated_power = l(:,5);
rated_luminousFlux = l(:,6);
rated_CCT = l(:,7);
rated_Ra = l(:,8);

for i = 1:8
    for j = 1:8
        temp_index = find(rack==i & branch==j) ;
        productsInBranch = product(temp_index(~isnan(product(temp_index))));
        branch_watts(i,j) = sum(rated_power(productsInBranch));
        branch_current(i,j) = branch_watts(i,j)/120;
        minWattage = min(rated_power(productsInBranch));
        minBranchCurrent(i,j) = minWattage/120;
    end
end

branchMinCurrentArray = reshape(minBranchCurrent,1,[]);
branchCurrentArray = reshape(branch_current,1,[]);

disp('dimming count')
for i = 1:20
    temp = sum(product==i&strcmp(orientation,'u')&housing==0);
    disp([num2str(i) ' ' num2str(temp)])
end

tm.product = product;
tm.sample = sample;
tm.branch = branch;
tm.rack = rack;
tm.socket = socket;
tm.housing = housing;
tm.dimming = dimming;
tm.orientation = orientation;
tm.rated_power = rated_power;
tm.rated_luminousFlux = rated_luminousFlux;
tm.rated_CCT = rated_CCT;
tm.rated_Ra = rated_Ra;
cd('C:\Users\dhstuart\Dropbox\CLTC\LED life testing\photometric data')
save('testMatrix.mat','tm')

